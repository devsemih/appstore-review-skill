package club.stride.app

import android.app.Application
import com.google.android.gms.ads.MobileAds
import club.stride.app.tracking.AutoTrackScheduler

class StrideApp : Application() {
    override fun onCreate() {
        super.onCreate()
        // Warm up the Mobile Ads SDK as early as possible so the first banner loads fast.
        MobileAds.initialize(this) {}
        AutoTrackScheduler.schedule(this)
    }
}
