package club.stride.app.auth

import android.content.Intent
import android.os.Bundle
import android.widget.Button
import android.widget.EditText
import android.widget.LinearLayout
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.FirebaseFirestore
import club.stride.app.MainActivity
import club.stride.app.R

class SignUpActivity : AppCompatActivity() {
    private val auth = FirebaseAuth.getInstance()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val name = EditText(this).apply { hint = "Display name" }
        val email = EditText(this).apply { hint = "Email" }
        val password = EditText(this).apply { hint = "Password" }
        val submit = Button(this).apply { text = getString(R.string.sign_up) }
        setContentView(LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            addView(name); addView(email); addView(password); addView(submit)
        })

        submit.setOnClickListener {
            auth.createUserWithEmailAndPassword(email.text.toString(), password.text.toString())
                .addOnSuccessListener { result ->
                    FirebaseFirestore.getInstance().collection("runners").document(result.user!!.uid)
                        .set(mapOf("displayName" to name.text.toString(), "clubs" to emptyList<String>()))
                    startActivity(Intent(this, MainActivity::class.java))
                    finish()
                }
                .addOnFailureListener { Toast.makeText(this, it.message, Toast.LENGTH_LONG).show() }
        }
    }
}
