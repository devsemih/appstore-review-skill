package club.stride.app.settings

import android.Manifest
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.widget.Button
import android.widget.LinearLayout
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import com.google.firebase.auth.FirebaseAuth
import club.stride.app.R
import club.stride.app.auth.SignUpActivity

class SettingsActivity : AppCompatActivity() {

    private val backgroundLocation =
        registerForActivityResult(ActivityResultContracts.RequestPermission()) { }

    private val foregroundLocation =
        registerForActivityResult(ActivityResultContracts.RequestMultiplePermissions()) { result ->
            if (result[Manifest.permission.ACCESS_FINE_LOCATION] == true) {
                backgroundLocation.launch(Manifest.permission.ACCESS_BACKGROUND_LOCATION)
            }
        }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val root = LinearLayout(this).apply { orientation = LinearLayout.VERTICAL }

        root.addView(Button(this).apply {
            text = "Auto-detect my runs"
            setOnClickListener {
                foregroundLocation.launch(
                    arrayOf(Manifest.permission.ACCESS_FINE_LOCATION, Manifest.permission.ACCESS_COARSE_LOCATION)
                )
            }
        })
        root.addView(Button(this).apply {
            text = "Privacy policy"
            setOnClickListener {
                startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(getString(R.string.privacy_policy_url))))
            }
        })
        root.addView(Button(this).apply {
            text = getString(R.string.log_out)
            setOnClickListener {
                FirebaseAuth.getInstance().signOut()
                startActivity(Intent(this@SettingsActivity, SignUpActivity::class.java))
                finishAffinity()
            }
        })
        setContentView(root)
    }
}
