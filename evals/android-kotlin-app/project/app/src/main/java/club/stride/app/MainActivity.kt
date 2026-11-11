package club.stride.app

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.widget.Button
import android.widget.LinearLayout
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.AdSize
import com.google.android.gms.ads.AdView
import com.google.android.material.dialog.MaterialAlertDialogBuilder
import com.google.android.ump.ConsentRequestParameters
import com.google.android.ump.UserMessagingPlatform
import com.google.firebase.auth.FirebaseAuth
import club.stride.app.auth.SignUpActivity
import club.stride.app.profile.ProfileActivity
import club.stride.app.settings.SettingsActivity
import club.stride.app.tracking.PartnerApps

class MainActivity : AppCompatActivity() {

    private val notificationPermission =
        registerForActivityResult(ActivityResultContracts.RequestPermission()) { /* app works either way */ }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (FirebaseAuth.getInstance().currentUser == null) {
            startActivity(Intent(this, SignUpActivity::class.java))
            finish()
            return
        }

        val root = LinearLayout(this).apply { orientation = LinearLayout.VERTICAL }
        root.addView(Button(this).apply {
            text = getString(R.string.change_avatar)
            setOnClickListener { startActivity(Intent(this@MainActivity, ProfileActivity::class.java)) }
        })
        root.addView(Button(this).apply {
            text = "Settings"
            setOnClickListener { startActivity(Intent(this@MainActivity, SettingsActivity::class.java)) }
        })
        if (PartnerApps.isStravaInstalled(this)) {
            root.addView(Button(this).apply { text = "Connect Strava" })
        }
        val adView = AdView(this).apply {
            adUnitId = "ca-app-pub-3940256099942544/6300978111"
            setAdSize(AdSize.BANNER)
        }
        root.addView(adView)
        setContentView(root)
        adView.loadAd(AdRequest.Builder().build())

        gatherConsent()
        maybeAskForNotifications()
    }

    private fun gatherConsent() {
        val consentInformation = UserMessagingPlatform.getConsentInformation(this)
        consentInformation.requestConsentInfoUpdate(
            this,
            ConsentRequestParameters.Builder().build(),
            { UserMessagingPlatform.loadAndShowConsentFormIfRequired(this) { } },
            { }
        )
    }

    /** Android 13+: explain first, then request POST_NOTIFICATIONS at runtime. Declining is respected. */
    private fun maybeAskForNotifications() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) return
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS) ==
            PackageManager.PERMISSION_GRANTED
        ) return
        MaterialAlertDialogBuilder(this)
            .setTitle(R.string.notif_rationale_title)
            .setMessage(R.string.notif_rationale_body)
            .setNegativeButton(R.string.not_now, null)
            .setPositiveButton(R.string.continue_label) { _, _ ->
                notificationPermission.launch(Manifest.permission.POST_NOTIFICATIONS)
            }
            .show()
    }
}
