package com.example.cameraView

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.content.MutableContextWrapper
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.ImageFormat
import android.graphics.Matrix
import android.graphics.YuvImage
import android.graphics.Paint
import android.graphics.SurfaceTexture
import android.util.Log
import android.view.Surface
import android.view.TextureView
import android.view.View

import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageProxy
import androidx.camera.core.Preview
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.core.content.ContextCompat
import androidx.lifecycle.LifecycleOwner
import com.google.common.util.concurrent.ListenableFuture
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import java.util.concurrent.Executors
import java.nio.ByteBuffer
import java.nio.ByteOrder

import android.graphics.Rect
import android.graphics.RectF
import android.net.Uri
import android.view.SurfaceHolder
import android.view.SurfaceView
import android.widget.FrameLayout.LayoutParams
import androidx.annotation.OptIn
import androidx.camera.core.AspectRatio
import androidx.camera.core.ExperimentalGetImage
import androidx.core.graphics.toRectF
import com.example.MainActivity
import com.example.db.FaceImageRecord
import com.example.db.ImagesVectorDB
import com.example.db.PersonDB
import com.example.db.RecognitionMetrics
import com.example.tensor_flow_project.FaceOverlayView
import com.example.TensorFlowModel.Facenet512
import com.example.TensorFlowModel.MediapipeFaceDetector
import com.example.db.ObjectBoxStore
import com.example.db.PersonRecord
import com.example.tensor_flow_project.PersonUseCase
import com.google.mediapipe.tasks.components.containers.Embedding

import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.platform.PlatformViewFactory

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.launch
import java.io.ByteArrayOutputStream
import kotlin.math.pow
import kotlin.math.sqrt

import kotlin.time.DurationUnit

import kotlin.time.measureTimedValue

@ExperimentalGetImage
class YourCameraViewFactory(private val activity: Activity, val messenger: BinaryMessenger, val mainActivity: MainActivity) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    var cameraPlatformView: CameraPlatformView? = null

    @OptIn(ExperimentalGetImage::class)
    override fun create(context: Context, id: Int, creationParams: Any?): PlatformView {

        cameraPlatformView = CameraPlatformView(activity, messenger  ,mainActivity )
        return cameraPlatformView!! // Pass activity, not context
    }
}

data class FaceRecognitionResult(
    val personName: String,
    val boundingBox: Rect
)

@SuppressLint("ViewConstructor")
@ExperimentalGetImage
class CameraPlatformView(
    context: Context,
    val messenger: BinaryMessenger,
    private val mainActivity: MainActivity
    ) : PlatformView {
    private var cameraFacing: Int = CameraSelector.LENS_FACING_BACK
    private val textureView: TextureView
    private var cameraProvider: ProcessCameraProvider? = null
    private var facenetModel: Facenet512? = null
    private var imagesVectorDB: ImagesVectorDB? = null
    private lateinit var personDb: PersonDB
    private var faceOverlay: FaceOverlayView? = null
    private var media: MediapipeFaceDetector? = null
    var predictions: Array<Prediction> = arrayOf()
    private var boundingBoxTransform: Matrix = Matrix()
    private lateinit var frameBitmap: Bitmap
    private var isBoundingBoxTransformedInitialized = false
    private var isProcessing = false
    private var isDetectionPaused = false
    private var overlayWidth: Int = 0
    private var overlayHeight: Int = 0
    private var imageTransform: Matrix = Matrix()
    private var isImageTransformedInitialized = false

    init {
        faceOverlay = FaceOverlayView(context)
        this.isImageTransformedInitialized = false

        this.isBoundingBoxTransformedInitialized = false

        // Initialize TextureView for camera preview
        textureView = TextureView(context).apply {
            layoutParams = LayoutParams(
                LayoutParams.MATCH_PARENT,
                LayoutParams.MATCH_PARENT
            )

            imagesVectorDB = ImagesVectorDB()
            personDb = PersonDB()
            ///LOAD MEDIAPIPE CLASS
            media = MediapipeFaceDetector(context = context)


            surfaceTextureListener = object : TextureView.SurfaceTextureListener {


            override fun onSurfaceTextureAvailable(surface: SurfaceTexture, width: Int, height: Int) {
                mainActivity.setSurfaceTexture(surface)

                startCamera(context, surface)

            }

            override fun onSurfaceTextureSizeChanged(surface: SurfaceTexture, width: Int, height: Int) {
                // Handle size changes if needed
            }

            override fun onSurfaceTextureDestroyed(surface: SurfaceTexture): Boolean {
                disposeCamera();
                return true
            }

            override fun onSurfaceTextureUpdated(surface: SurfaceTexture) {
                // Called every time the surface texture is updated
            } }
        }


    }

    private fun loadFile(context: Context){
        if(facenetModel == null){
            facenetModel = Facenet512(context)
            facenetModel?.loadModel(context)
            io.flutter.Log.e("load model","initial Loading")
        } else {
            io.flutter.Log.e("load model","model already loaded")
        }
    }

    fun disposeCamera(){
        cameraProvider?.unbindAll()
    }

    fun startCamera(context: Context, surfaceTexture: SurfaceTexture) {
        val cameraProviderFuture: ListenableFuture<ProcessCameraProvider> = ProcessCameraProvider.getInstance(getActivity(context))

        ///LOAD FACENET_512
        loadFile(context)

        cameraProviderFuture.addListener({
            cameraProvider = cameraProviderFuture.get()
            mainActivity.setCameraProvider(cameraProviderFuture.get())

            val preview = Preview.Builder()
                .build()
                .apply {
                    setSurfaceProvider { request ->
                        surfaceTexture.setDefaultBufferSize(request.resolution.width, request.resolution.height)
                        val surface = Surface(surfaceTexture)
                        request.provideSurface(surface, Executors.newSingleThreadExecutor()) {}
                    }
                }


            val cameraSelector = CameraSelector.DEFAULT_FRONT_CAMERA // Or FRONT
            val lifecycleOwner = getActivity(context) as LifecycleOwner
            try {
                cameraProvider?.unbindAll()
                cameraProvider?.bindToLifecycle(
                    lifecycleOwner,
                    cameraSelector,
                    preview,
                    ImageAnalysis.Builder()
                        .setTargetAspectRatio(AspectRatio.RATIO_16_9)
                        .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                        .setOutputImageFormat(ImageAnalysis.OUTPUT_IMAGE_FORMAT_RGBA_8888)
                        .build()
                        .also {
                            it.setAnalyzer(Executors.newSingleThreadExecutor(), ImageAnalysis.Analyzer { imageProxy ->
                                processImage(imageProxy,context)
                            })
                        }

                )
            } catch (exc: Exception) {
                Log.e("CameraX", "Use case binding failed", exc)
            }
        }, ContextCompat.getMainExecutor(context))
    }

    override fun getView(): View {
        return textureView
    }

    override fun dispose() {
        facenetModel?.close()
    }

    override fun onFlutterViewDetached() {
        cameraProvider?.unbindAll()
        isDetectionPaused = true
        super.onFlutterViewDetached()
    }

    private fun getActivity(context: Context): Activity {
        return if (context is Activity) {
            context
        } else {
            (context as MutableContextWrapper).baseContext as Activity
        }
    }

    private fun processImage(imageProxy: ImageProxy,context: Context) {
        if (isProcessing) return  // Skip frame if another is being processed
        isProcessing = true
        detectAndrecognize(imageProxy)
    }



    data class Prediction(var bbox: RectF, var label: String)
    inner class BoundingBoxOverlay(context: Context) :
        SurfaceView(context), SurfaceHolder.Callback {

        private val boxPaint =
            Paint().apply {
                color = Color.parseColor("#4D90caf9")
                style = Paint.Style.FILL
            }
        private val textPaint =
            Paint().apply {
                strokeWidth = 2.0f
                textSize = 36f
                color = Color.WHITE
            }

        override fun surfaceCreated(holder: SurfaceHolder) {}

        override fun surfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {}

        override fun surfaceDestroyed(holder: SurfaceHolder) {}

        override fun onDraw(canvas: Canvas) {
            predictions.forEach {
                canvas.drawRoundRect(it.bbox, 16f, 16f, boxPaint)
                canvas.drawText(it.label, it.bbox.centerX(), it.bbox.centerY(), textPaint)
            }
        }
    }



     fun detectAndrecognize(imageProxy: ImageProxy){
        CoroutineScope(Dispatchers.Default).launch {
            val (metrics, results) =  detectMediaPipeFun(imageProxy)
            results.forEach {
                    (name, boundingBox) ->
                val box = boundingBox.toRectF()
                var personName = name
                if (personDb.getCount().toInt() == 0) {
                    personName = ""
                }
                boundingBoxTransform.mapRect(box)

                mainActivity.sendFrameData(
                    mapOf(
                        "name" to personName,
                        "left" to boundingBox.left,
                        "top" to boundingBox.top,
                        "width" to frameBitmap.width,
                        "height" to frameBitmap.height,
                        "bottom" to boundingBox.bottom,
                        "right" to boundingBox.right
                    )
                ) // Convert to List<Float> for JSON compatibility
            }
            isProcessing = false
            imageProxy.close()
        }
    }


      suspend fun detectMediaPipeFun(imageProxy: ImageProxy): Pair<RecognitionMetrics?, List<FaceRecognitionResult>> {

        var image  = imageProxy.image

        Log.e("IMAGE BIT", "HEIGHT ${imageProxy.image?.height} || WIDTH ${imageProxy.image?.width} || ${image!!.planes[0].buffer}")

        frameBitmap = Bitmap.createBitmap(
                image.width,
                image.height,
                Bitmap.Config.ARGB_8888
            )


            Log.e("IMAGE BIT", "the image bit ${image.planes[0].buffer}")


        frameBitmap.copyPixelsFromBuffer(image.planes[0].buffer)

        if (!isImageTransformedInitialized) {
            imageTransform = Matrix()
            imageTransform.apply { postRotate(imageProxy.imageInfo.rotationDegrees.toFloat()) }
            isImageTransformedInitialized = true
        }
        if (!isBoundingBoxTransformedInitialized) {
            boundingBoxTransform = Matrix()
            boundingBoxTransform.apply {
                setScale(
                    overlayWidth / frameBitmap.width.toFloat(),
                    overlayHeight / frameBitmap.height.toFloat()
                )
                if (cameraFacing == CameraSelector.LENS_FACING_FRONT) {
                    // Mirror the bounding box coordinates
                    // for front-facing camera
                    postScale(
                        -1f,
                        1f,
                        overlayWidth.toFloat() / 2.0f,
                        overlayHeight.toFloat() / 2.0f
                    )
                }
            }
            isBoundingBoxTransformedInitialized = true
        }

        frameBitmap = Bitmap.createBitmap(
                frameBitmap,
                0,
                0,
                frameBitmap.width,
                frameBitmap.height,
                imageTransform,
                false
            )

            Log.e("IMAGE BIT", "THE CURRENT BIT $frameBitmap")

                val (faceDetectionResult, t1) =
            measureTimedValue { media?.getAllCroppedFaces(frameBitmap) }
        val faceRecognitionResults = ArrayList<FaceRecognitionResult>()
        var avgT2 = 0L
        var avgT3 = 0L
        var avgT4 = 0L
        Log.e("Face", "faceDetectionResult $faceDetectionResult")

        for (result in faceDetectionResult!!) {
            // Get the embedding for the cropped face (query embedding)
            val (croppedBitmap, boundingBox) = result
            val (embedding, t2) = measureTimedValue { facenetModel?.getFaceEmbedding(croppedBitmap) }
            avgT2 += t2.toLong(DurationUnit.MILLISECONDS)
            if (embedding != null) {
                Log.e("Face", "THE DATA $embedding $boundingBox")
                avgT2 += t2.toLong(DurationUnit.MILLISECONDS)
                // Perform nearest-neighbor search
                val (recognitionResult, t3) =
                    measureTimedValue { imagesVectorDB?.getNearestEmbeddingPersonName(embedding) }
                avgT3 += t3.toLong(DurationUnit.MILLISECONDS)
                if (recognitionResult == null) {
                    faceRecognitionResults.add(FaceRecognitionResult("Not recognized", boundingBox))
                    continue
                }

                // Calculate cosine similarity between the nearest-neighbor
                // and the query embedding
                val distance = cosineDistance(embedding, recognitionResult.faceEmbedding)

                Log.e("Face", "DISTANCE $distance")
                // If the distance > 0.4, we recognize the person
                // else we conclude that the face does not match enough
                if (distance > 0.8) {
                    faceRecognitionResults.add(
                        FaceRecognitionResult(recognitionResult.personName, boundingBox)
                    )
                } else {
                    faceRecognitionResults.add(
                        FaceRecognitionResult("Not recognized", boundingBox)
                    )
                }
            } else {
                Log.e("Face", "EMBEDDING DATA IS NULL")
            }


        }
        val metrics =
            if (faceDetectionResult.isNotEmpty()) {
                RecognitionMetrics(
                    timeFaceDetection = t1.toLong(DurationUnit.MILLISECONDS),
                    timeFaceEmbedding = avgT2 / faceDetectionResult.size,
                    timeVectorSearch = avgT3 / faceDetectionResult.size,
                )
            } else {
                null
            }

        return Pair(metrics, faceRecognitionResults)

    }

    private fun cosineDistance(x1: FloatArray, x2: FloatArray): Float {
        var mag1 = 0.0f
        var mag2 = 0.0f
        var product = 0.0f
        for (i in x1.indices) {
            mag1 += x1[i].pow(2)
            mag2 += x2[i].pow(2)
            product += x1[i] * x2[i]
        }
        mag1 = sqrt(mag1)
        mag2 = sqrt(mag2)
        return product / (mag1 * mag2)
    }


    fun getAll(): Flow<MutableList<PersonRecord>> {
        var result :  Flow<MutableList<PersonRecord>>? = null
        result =  personDb.getAll()
        return  result
    }

    fun getVectorDBlIST(): List<FaceImageRecord>? {
        var data  = imagesVectorDB?.getAllFaceRecords()
        return  data
    }

    fun removePerson( personID: Long): Boolean {
        var value : Boolean = false
        CoroutineScope(Dispatchers.Default).launch {
           var data =  imagesVectorDB?.removeFaceImageRecord(personID)
            if(data == null){
                io.flutter.Log.e("EMBEDDING", "imageVector is null")
                value = false
                return@launch
            }
            personDb.removePerson(personID)
            value = true

        }
        value = false
        return value
    }

    fun updatePhoto(personID: Long,imageUri: Uri?): Boolean{
        var value : Boolean = false
        CoroutineScope(Dispatchers.Default).launch {
            var embedding =    imageUpdateValue(imageUri)

            if(embedding == null){
                io.flutter.Log.e("EMBEDDING", "embedding is null $embedding")
                value = false
                return@launch
            }
            io.flutter.Log.e("EMBEDDING", "embedding: $embedding")
            var isUpdateDone =   updateThePersonPhoto(personID,embedding)
            io.flutter.Log.e("EMBEDDING", "embedding TRUE FALSE : $isUpdateDone")
        }


        return true
    }

    suspend fun imageUpdateValue(imageUri: Uri?) : FloatArray? {
       var embeddings: FloatArray = floatArrayOf()
        if (imageUri == null) {
            return null
        }
        val faceDetectionResult = media?.getCroppedFace(imageUri!!)

        io.flutter.Log.e("EMBEDDING", "faceDetectionResult: $faceDetectionResult")

        if (faceDetectionResult != null && faceDetectionResult.isSuccess) {
            if (faceDetectionResult.getOrNull() != null) {

                val embedding = facenetModel?.getFaceEmbedding(faceDetectionResult.getOrNull()!!)
                io.flutter.Log.e("EMBEDDING", "embedding: $embedding")
                if (embedding != null) {
                    return embedding

                }
            }

        }

        return null

    }

   suspend fun updateThePersonPhoto(personID: Long,embedding: FloatArray): Boolean {

       var person =    personDb.getPersonById(personID)

         if (person == null) {
              io.flutter.Log.e("EMBEDDING", "person is null")
              return false
         }
       io.flutter.Log.e("EMBEDDING", "Person ${person?.personName}")
       ///find the user and update the person data with the new embedding
       var imageVector =    imagesVectorDB?.getPersonImage(person.personID)
       if (imageVector == null) {
           io.flutter.Log.e("EMBEDDING", "imageVector is null")
           return  false
       }

       io.flutter.Log.e("EMBEDDING", "imageVector ${imageVector.personName}")


       imageVector.faceEmbedding = embedding
       var data =   imagesVectorDB?.addFaceImageRecord(imageVector)
       if(data == null){
           io.flutter.Log.e("EMBEDDING", "imageVector is null")
           return  false
       }
       io.flutter.Log.e("EMBEDDING", "imageVector is updated successfully $data")
       return  true
    }

    fun addImage(uriList: List<Uri>,personName: String, imageUri: Uri?): Boolean {
        var personDB = PersonDB()
        var personUseCase = PersonUseCase(personDB)


        CoroutineScope(Dispatchers.Default).launch {
            // Guard: Check if imageUri is null
            if (imageUri == null) {
                mainActivity.sendEmbeddingValue("Error: imageUri is null")
                return@launch
            }

            // Guard: Check if media is null
            if (media == null) {
                mainActivity.sendEmbeddingValue("Error: media is null")
                return@launch
            }

            val faceDetectionResult = media?.getCroppedFace(imageUri)
            io.flutter.Log.e("EMBEDDING", "faceDetectionResult: $faceDetectionResult")
            io.flutter.Log.e("EMBEDDING", "HEIGHT: ${faceDetectionResult.toString()}")

            // Guard: Check if face detection was successful
            if (faceDetectionResult?.isSuccess != true) {
                val data = mapOf("embedding" to "Error: face detection failed", "personName" to null)
                mainActivity.sendEmbeddingValue(data)
                return@launch
            }

            val faceBitmap = faceDetectionResult.getOrNull()

            // Guard: Check if faceBitmap is null
            if (faceBitmap == null) {
                val data = mapOf("embedding" to "Error: faceBitmap is null", "personName" to null)
                mainActivity.sendEmbeddingValue(data)
                return@launch
            }

            val embedding = facenetModel?.getFaceEmbedding(faceBitmap)
            io.flutter.Log.e("EMBEDDING", "embedding: $embedding")

            // Guard: Check if embedding is null
            if (embedding == null) {
                val data = mapOf("embedding" to "Error: embedding is null", "personName" to null)
                mainActivity.sendEmbeddingValue(data)
                return@launch
            }

            // Check for existing person using embedding
            val (recognitionResult, _) = measureTimedValue {
                imagesVectorDB?.getNearestEmbeddingPersonName(embedding)
            }
            // Guard: If person already exists
            if (recognitionResult != null) {
                val distance = cosineDistance(embedding, recognitionResult!!.faceEmbedding)

                if(distance > 0.8){
                    val data = mapOf("embedding" to "Error: Face is already exist", "personName" to null)
                    mainActivity.sendEmbeddingValue(data)
                    return@launch
                }


//                io.flutter.Log.e("EMBEDDING", "Person already exists: ${recognitionResult.personName}")
//                mainActivity.sendEmbeddingValue("Error: person already exists")
//                return@launch
            }

            var isNameexist = personUseCase.searchNameExistingShouldNotAdd(personName!!)

            if(isNameexist == true){
                val data = mapOf("embedding" to "Error: FaceName is already exist", "personName" to null)
                mainActivity.sendEmbeddingValue(data)
                return@launch
            }

            val id =
                personUseCase.addPerson(
                    personName.toString(),
                    uriList.size.toLong()
                )

            // Add the new face record
            imagesVectorDB?.addFaceImageRecord(
                FaceImageRecord(
                    personID = id,
                    personName = personName,
                    faceEmbedding = embedding
                )
            )

            val successData = mapOf("embedding" to "submitted", "personName" to personName)
            mainActivity.sendEmbeddingValue(successData)
        }

        return false
    }

}

