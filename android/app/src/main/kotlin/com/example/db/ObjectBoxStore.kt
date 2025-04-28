package com.example.db

import android.content.Context
import io.flutter.Log
import io.objectbox.BoxStore


object ObjectBoxStore {
    lateinit var store: BoxStore
        private set

    fun init(context: Context) {
        Log.d("OBJECT BOX", "Using ObjectBox ${BoxStore.getVersion()} (${BoxStore.getVersionNative()})")
        store = MyObjectBox.builder().androidContext(context).build()
    }
}
