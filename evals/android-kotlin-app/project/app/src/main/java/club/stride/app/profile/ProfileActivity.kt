package club.stride.app.profile

import android.Manifest
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import android.provider.MediaStore
import android.widget.GridView
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.SimpleCursorAdapter
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import coil.load
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.storage.FirebaseStorage

/** Lets the runner choose a profile picture (avatar) from their gallery. */
class ProfileActivity : AppCompatActivity() {

    private lateinit var avatar: ImageView
    private lateinit var grid: GridView

    private val mediaPermission =
        registerForActivityResult(ActivityResultContracts.RequestPermission()) { granted ->
            if (granted) showGallery()
        }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        avatar = ImageView(this)
        grid = GridView(this).apply { numColumns = 3 }
        setContentView(LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            addView(avatar); addView(grid)
        })

        if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_MEDIA_IMAGES) ==
            PackageManager.PERMISSION_GRANTED
        ) showGallery() else mediaPermission.launch(Manifest.permission.READ_MEDIA_IMAGES)
    }

    /** Custom in-app gallery built on a full MediaStore query. */
    private fun showGallery() {
        val cursor = contentResolver.query(
            MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
            arrayOf(MediaStore.Images.Media._ID, MediaStore.Images.Media.DATA),
            null, null,
            "${MediaStore.Images.Media.DATE_ADDED} DESC"
        )
        grid.adapter = SimpleCursorAdapter(
            this, android.R.layout.simple_list_item_1, cursor,
            arrayOf(MediaStore.Images.Media.DATA), intArrayOf(android.R.id.text1), 0
        )
        grid.setOnItemClickListener { _, _, _, id ->
            val uri = Uri.withAppendedPath(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, id.toString())
            uploadAvatar(uri)
        }
    }

    private fun uploadAvatar(uri: Uri) {
        val uid = FirebaseAuth.getInstance().currentUser?.uid ?: return
        FirebaseStorage.getInstance().reference.child("avatars/$uid.jpg").putFile(uri)
            .addOnSuccessListener { avatar.load(uri) }
    }
}
