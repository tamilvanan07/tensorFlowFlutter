package com.example.TensorFlowModel

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Matrix
import android.graphics.Rect
import android.net.Uri
import android.util.Log
import androidx.core.graphics.toRect
import androidx.exifinterface.media.ExifInterface
import com.example.exception.AppException
import com.example.exception.ErrorCode
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File
import java.io.FileOutputStream

import com.google.mediapipe.framework.image.BitmapImageBuilder
import com.google.mediapipe.tasks.core.BaseOptions
import com.google.mediapipe.tasks.vision.core.RunningMode
import com.google.mediapipe.tasks.vision.facedetector.FaceDetector


class MediapipeFaceDetector(private val context: Context) {
    private lateinit var faceDetector :FaceDetector
    // The model is stored in the assets folder
    private val modelName = "blaze_face_short_range.tflite"
    private val baseOptions = BaseOptions.builder().setModelAssetPath(modelName).build()
    private val faceDetectorOptions =
        FaceDetector.FaceDetectorOptions.builder()
            .setBaseOptions(baseOptions)
            .setRunningMode(RunningMode.IMAGE)
            .build()

    init {
         faceDetector = FaceDetector.createFromOptions(context, faceDetectorOptions)
    }

    suspend fun getCroppedFace(imageUri: Uri): Result<Bitmap> =
        withContext(Dispatchers.IO) {
            var imageInputStream =
                context.contentResolver.openInputStream(imageUri)
                    ?: return@withContext Result.failure<Bitmap>(
                        AppException(ErrorCode.FACE_DETECTOR_FAILURE)
                    )
            var imageBitmap = BitmapFactory.decodeStream(imageInputStream)
            imageInputStream.close()

            // Re-create an input-stream to reset its position
            // InputStream returns false with markSupported(), hence we cannot
            // reset its position
            // Without recreating the inputStream, no exif-data is read
            imageInputStream =
                context.contentResolver.openInputStream(imageUri)
                    ?: return@withContext Result.failure<Bitmap>(
                        AppException(ErrorCode.FACE_DETECTOR_FAILURE)
                    )
            val exifInterface = ExifInterface(imageInputStream)
            imageBitmap =
                when (
                    exifInterface.getAttributeInt(
                        ExifInterface.TAG_ORIENTATION,
                        ExifInterface.ORIENTATION_UNDEFINED
                    )
                ) {
                    ExifInterface.ORIENTATION_ROTATE_90 -> rotateBitmap(imageBitmap, 90f)
                    ExifInterface.ORIENTATION_ROTATE_180 -> rotateBitmap(imageBitmap, 180f)
                    ExifInterface.ORIENTATION_ROTATE_270 -> rotateBitmap(imageBitmap, 270f)
                    else -> imageBitmap
                }
            imageInputStream.close()

            // We need exactly one face in the image, in other cases, return the
            // necessary errors
            val faces = faceDetector.detect(BitmapImageBuilder(imageBitmap).build()).detections()
            if (faces.size > 1) {
                return@withContext Result.failure<Bitmap>(AppException(ErrorCode.MULTIPLE_FACES))
            } else if (faces.isEmpty()) {
                return@withContext Result.failure<Bitmap>(AppException(ErrorCode.NO_FACE))
            } else {
                // Validate the bounding box and
                // return the cropped face
                val rect = faces[0].boundingBox().toRect()
                if (validateRect(imageBitmap, rect)) {
                    val croppedBitmap =
                        Bitmap.createBitmap(
                            imageBitmap,
                            rect.left,
                            rect.top,
                            rect.width(),
                            rect.height()
                        )
                    return@withContext Result.success(croppedBitmap)
                } else {
                    return@withContext Result.failure<Bitmap>(
                        AppException(ErrorCode.FACE_DETECTOR_FAILURE)
                    )
                }
            }
        }

    // Detects multiple faces from the `frameBitmap`
    // and returns pairs of (croppedFace , boundingBoxRect)
    // Used by ImageVectorUseCase.kt
    suspend fun getAllCroppedFaces(frameBitmap: Bitmap): List<Pair<Bitmap, Rect>> =
        withContext(Dispatchers.IO) {
            Log.e("IMAGE BIT", "MEDIApipe $frameBitmap")
            val detectedFaces = faceDetector
                .detect(BitmapImageBuilder(frameBitmap).build())
                .detections()
                .filter { validateRect(frameBitmap, it.boundingBox().toRect()) }
                .map { it.boundingBox().toRect() }
            return@withContext detectedFaces.map { rect ->
                    Log.e("IMAGE BIT", "rect ${rect.left},${ rect.top }")
                    val croppedBitmap =
                        Bitmap.createBitmap(
                            frameBitmap,
                            rect.left,
                            rect.top,
                            rect.width(),
                            rect.height()
                        )
                    Pair(croppedBitmap, rect)
                }
        }

//    suspend fun getAllCroppedFaces(frameBitmap: Bitmap): List<Pair<Bitmap, Rect>> =
//        withContext(Dispatchers.IO) {
//            try {
//                Log.e("IMAGE BIT", "MEDIApipe $frameBitmap")
//
//                val detectedFaces = faceDetector
//                    .detect(BitmapImageBuilder(frameBitmap).build())
//                    .detections()
////                    .filter { validateRect(frameBitmap, it.boundingBox().toRect()) }
//                    .map { it.boundingBox().toRect() }
//
//                Log.e("IMAGE BIT", "detectedFaces Faces: ${detectedFaces.size}")
//
//                var croppedFace = detectedFaces.mapNotNull { rect ->
//                    io.flutter.Log.e("bit map", "width ${rect.width()}, height ${rect.height()}")
//                    io.flutter.Log.e("bit map", "x ${rect.left}, y ${rect.top}")
//
////                    val width = min(rect.width(), frameBitmap.width - rect.left)
////                    val height = min(rect.height(), frameBitmap.height - rect.top)
//
//                    if (true) {
//                        try {
//                            val croppedBitmap = withContext(Dispatchers.Main) {
//                                Bitmap.createBitmap(
//                                    frameBitmap,
//                                    rect.left,
//                                    rect.top,
//                                    128,
//                                    128
//                                )
//                            }
//                            io.flutter.Log.e("bit map", "Cropped Bitmap: $croppedBitmap")
//                            io.flutter.Log.e("bit map", "Rect: $rect")
//                            Pair(croppedBitmap, rect)
//                        } catch (e: Exception) {
//                            io.flutter.Log.e("bit map", "Bitmap cropping failed: ${e.message}")
//                            null
//                        }
//                    } else {
//                        io.flutter.Log.e("bit map", "THE VALUE IS NULL: Invalid bounding box")
//                        null
//                    }
//                }
//                Log.e("IMAGE BIT", "Detected Faces: ${croppedFace.size}")
//                return@withContext croppedFace
//            } catch (e: Exception) {
//                Log.e("IMAGE BIT", "Error in face detection: ${e.message}")
//                emptyList()
//            }
//        }


    // DEBUG: For testing purpose, saves the Bitmap to the app's private storage
    fun saveBitmap(context: Context, image: Bitmap, name: String) {
        val fileOutputStream = FileOutputStream(File(context.filesDir.absolutePath + "/$name.png"))
        image.compress(Bitmap.CompressFormat.PNG, 100, fileOutputStream)
    }

    private fun rotateBitmap(source: Bitmap, degrees: Float): Bitmap {
        val matrix = Matrix()
        matrix.postRotate(degrees)
        return Bitmap.createBitmap(source, 0, 0, source.width, source.height, matrix, false)
    }

    // Check if the bounds of `boundingBox` fit within the
    // limits of `cameraFrameBitmap`
    private fun validateRect(cameraFrameBitmap: Bitmap, boundingBox: Rect): Boolean {
        return boundingBox.left >= 0 &&
                boundingBox.top >= 0 &&
                (boundingBox.left + boundingBox.width()) < cameraFrameBitmap.width &&
                (boundingBox.top + boundingBox.height()) < cameraFrameBitmap.height
    }
}

//fun detectFaceAndPerson(imageProxy: ImageProxy){
//    val predictions = ArrayList<Prediction>()
//    CoroutineScope(Dispatchers.Default).launch {
//        val (metrics, results) =    detectMediaPipeFun(imageProxy)
//        results.forEach {
//                (name, boundingBox, spoofResult) ->
//            val box = boundingBox.toRectF()
//            var personName = name
//
//            if (getNumPeople().toInt() == 0) {
//                personName = ""
//            }
//            if (spoofResult != null && spoofResult.isSpoof) {
//                personName = "$personName (Spoof: ${spoofResult.score})"
//            }
//            boundingBoxTransform.mapRect(box)
//            predictions.add(Prediction(box, personName))
//
//            mainActivity.sendFrameData(
//                mapOf(
//                    "name" to personName,
//                    "left" to boundingBox.left,
//                    "top" to boundingBox.top,
//                    "width" to frameBitmap.width,
//                    "height" to frameBitmap.height,
//                    "bottom" to boundingBox.bottom,
//                    "right" to boundingBox.right
//                )
//            )
//        }
//
//    }
//    isProcessing = false
//    imageProxy.close()
//}