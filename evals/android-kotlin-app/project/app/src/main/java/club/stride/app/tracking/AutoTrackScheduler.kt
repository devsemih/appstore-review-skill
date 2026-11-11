package club.stride.app.tracking

import android.annotation.SuppressLint
import android.content.Context
import androidx.work.CoroutineWorker
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.WorkerParameters
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.Priority
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.FirebaseFirestore
import kotlinx.coroutines.tasks.await
import java.util.concurrent.TimeUnit

/** Detects runs automatically by sampling location every 15 minutes, even when the app is closed. */
object AutoTrackScheduler {
    fun schedule(context: Context) {
        val request = PeriodicWorkRequestBuilder<LocationSampleWorker>(15, TimeUnit.MINUTES).build()
        WorkManager.getInstance(context)
            .enqueueUniquePeriodicWork("auto-track", ExistingPeriodicWorkPolicy.KEEP, request)
    }
}

class LocationSampleWorker(context: Context, params: WorkerParameters) : CoroutineWorker(context, params) {
    @SuppressLint("MissingPermission")
    override suspend fun doWork(): Result {
        val uid = FirebaseAuth.getInstance().currentUser?.uid ?: return Result.success()
        val location = LocationServices.getFusedLocationProviderClient(applicationContext)
            .getCurrentLocation(Priority.PRIORITY_HIGH_ACCURACY, null)
            .await() ?: return Result.success()
        FirebaseFirestore.getInstance().collection("runners").document(uid)
            .collection("samples")
            .add(mapOf("lat" to location.latitude, "lng" to location.longitude, "t" to System.currentTimeMillis()))
        return Result.success()
    }
}
