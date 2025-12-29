package com.example.flutter_firebase

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import com.yandex.mapkit.MapKitFactory
import android.os.Build
import androidx.annotation.RequiresApi


class MainActivity : FlutterActivity(){
	@RequiresApi(Build.VERSION_CODES.O)
	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		MapKitFactory.setApiKey("b396a8d1-920e-4e5d-9ebc-2a09267f9c05")
		MapKitFactory.initialize(this)
		super.configureFlutterEngine(flutterEngine)
	}
}