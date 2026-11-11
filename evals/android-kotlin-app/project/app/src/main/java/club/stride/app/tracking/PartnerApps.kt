package club.stride.app.tracking

import android.content.Context
import android.content.pm.PackageManager

object PartnerApps {
    private const val STRAVA = "com.strava"

    /** Checks the full list of installed apps to decide whether to offer the Strava integration. */
    fun isStravaInstalled(context: Context): Boolean =
        context.packageManager.getInstalledApplications(PackageManager.GET_META_DATA)
            .any { it.packageName == STRAVA }
}
