package com.example

import android.graphics.SurfaceTexture
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.widget.FrameLayout
import androidx.annotation.OptIn
import androidx.camera.core.ExperimentalGetImage
import androidx.camera.lifecycle.ProcessCameraProvider
import com.example.db.ObjectBoxStore
import com.example.db.PersonDB
import com.example.cameraView.CameraPlatformView
import com.example.tensor_flow_project.FaceOverlayView
import com.example.tensor_flow_project.PersonUseCase

import com.example.cameraView.YourCameraViewFactory
import com.example.db.FaceImageRecord
import com.example.db.PersonRecord
import com.google.gson.Gson
import io.flutter.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.withContext
import java.io.File
import kotlin.math.log


@ExperimentalGetImage
class MainActivity : FlutterActivity() {
    private val CHANNEL = "camera_preview"
    private val EVENT_CHANNEL = "camera_event_channel"
    private var eventSink: EventChannel.EventSink? = null
    private var results:  MethodChannel.Result? = null
    private var cameraProvider: ProcessCameraProvider? = null
    private var surfaceTexture: SurfaceTexture? = null
    private val mainHandler = Handler(Looper.getMainLooper())
    lateinit var yourCameraViewFactory: YourCameraViewFactory

    @OptIn(ExperimentalGetImage::class)
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine)
       ObjectBoxStore.init(this)
        val faceOverlayView = FaceOverlayView(this)
        addContentView(faceOverlayView, FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.MATCH_PARENT
        ))
        yourCameraViewFactory = YourCameraViewFactory(
            this, flutterEngine.dartExecutor.binaryMessenger, this
        )

        flutterEngine.platformViewsController.registry.registerViewFactory("camera_preview", yourCameraViewFactory)

        // ✅ Method Channel setup
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->

            results = result // Store the result to use later
            when (call.method) {
                "stopCamera" -> {
                    yourCameraViewFactory.cameraPlatformView!!.disposeCamera()
                    result.success("Camera stopped")
                }

                "faceRecogniseCamera" -> {
                    val arguments = call.arguments as? Map<*, *>
                    val image = arguments?.get("imageURI") as? String
                    val personName = arguments?.get("personName") as? String
                    var urivalue =  Uri.fromFile( File("$image"))
                    val uriList: List<Uri> = listOf(urivalue)

                    if(yourCameraViewFactory.cameraPlatformView == null){
                        yourCameraViewFactory.cameraPlatformView = CameraPlatformView(
                            this,
                            flutterEngine.dartExecutor.binaryMessenger,
                            this
                        )
                    }
                    uriList.forEach {
                        yourCameraViewFactory.cameraPlatformView!!.addImage(uriList,personName!!,it)
                    }


                }

                "GETALL" -> {
                 var result =    yourCameraViewFactory.cameraPlatformView!!.getAll()
                    convertFlowToJson(result)

                }

                "vectorDBDATA" -> {
                    var result =    yourCameraViewFactory.cameraPlatformView!!.getVectorDBlIST()
                    convertFlowToJsonList(result)

                }

                "removePerson" -> {
                    val arguments = call.arguments as? Map<*, *>
                    val id = arguments?.get("id") as? String
                    var isRemoved = yourCameraViewFactory.cameraPlatformView!!.removePerson(id!!.toLong())
                    CoroutineScope(Dispatchers.Default).launch {
                        if(isRemoved == true){
                            result.success(true)}
                        else{
                           result.success(false)
                        }
                    }

                }

                "updatePersonPhotoEmbedding" -> {
                    val arguments = call.arguments as? Map<*, *>
                    val image = arguments?.get("imageURI") as? String
                    val personName = arguments?.get("id") as? String
                    var urivalue =  Uri.fromFile(File("$image"))

                    io.flutter.Log.e("THE PASSED MAP","THE URI $urivalue $personName")
                    var isUpdated = yourCameraViewFactory.cameraPlatformView!!.updatePhoto(personName!!.toLong(),urivalue)

                    if(isUpdated == true){
                        result.success(true)}
                    else{
                        result.success(false)
                    }
                }

                "startCameras" -> {
                    yourCameraViewFactory.cameraPlatformView!!.startCamera(this,surfaceTexture!!)
                    results?.success("Camera started")
                }
                else -> result.notImplemented()
            }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                @OptIn(ExperimentalGetImage::class)
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events // Assign eventSink when a Flutter listener is attached
                }

                override fun onCancel(arguments: Any?) {

                    eventSink = null // Stop sending events when Flutter listener is removed
                }
            }
        )

    }

    // Method to send data (ensure eventSink is not null)
    fun sendFrameData(data: Any) {
        mainHandler.post{
            eventSink?.success(data)// Ensure this is never null
        }
    }

    // Call this from wherever you're initializing cameraProvider
    fun setCameraProvider(provider: ProcessCameraProvider) {
        cameraProvider = provider
    }

    // Call this from wherever you're initializing cameraProvider
    fun setSurfaceTexture(surface: SurfaceTexture) {
        surfaceTexture = surface
    }

    fun sendEmbeddingValue(any: Any) {
        results?.success(any)

    }


     fun convertFlowToJson(flow: Flow<MutableList<PersonRecord>>) {
        val gson = Gson()
         CoroutineScope(Dispatchers.Default).launch {
             val fullList = flow.first() // gets the *first* full list emitted
             io.flutter.Log.e("THE PASSED MAP","THE LIST $fullList")
             val json = gson.toJson(fullList)
             io.flutter.Log.e("THE PASSED MAP","THE JSON LIST $json")
             withContext(Dispatchers.Main) {
                 results?.success(json)
             }

         }

    }

    fun convertFlowToJsonList(flow: List<FaceImageRecord>?) {
        val gson = Gson()
        CoroutineScope(Dispatchers.Default).launch {
            val fullList = flow?.first() // gets the *first* full list emitted
            io.flutter.Log.e("THE PASSED MAP","THE LIST $fullList")
            val json = gson.toJson(fullList)
            io.flutter.Log.e("THE PASSED MAP","THE JSON LIST $json")
            withContext(Dispatchers.Main) {
                results?.success(json)
            }

        }

    }

}

