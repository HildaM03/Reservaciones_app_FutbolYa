// lib/profile_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:resrevacion_canchas/login_users_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<String> _getNumeroIdentidad(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();
    if (doc.exists) {
      return doc.data()?['numeroIdentidad'] ?? 'No registrado';
    }
    return 'No registrado';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Colores
    final Color azulElectrico = const Color(0xFF0D47A1);
    final Color naranjaFuerte = const Color(0xFFFF6F00);
    final Color verde = const Color(0xFF2E7D32);

    final creationDate = user?.metadata.creationTime != null
        ? DateFormat('dd/MM/yyyy').format(user!.metadata.creationTime!)
        : 'Desconocida';

    final lastSignIn = user?.metadata.lastSignInTime != null
        ? DateFormat('dd/MM/yyyy hh:mm a').format(user!.metadata.lastSignInTime!.toLocal())
        : 'Desconocido';

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Perfil', style: TextStyle(color: Colors.white)),
        backgroundColor: azulElectrico,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Foto de perfil
            CircleAvatar(
              radius: 50,
              backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
              child: user?.photoURL == null
                  ? const Icon(Icons.person, size: 50, color: Colors.white)
                  : null,
              backgroundColor: azulElectrico,
            ),
            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Información de Usuario',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: azulElectrico,
                ),
              ),
            ),
            const Divider(thickness: 1.2),
            const SizedBox(height: 10),

            _buildField(
              icon: Icons.person,
              iconColor: naranjaFuerte,
              label: 'Nombre',
              value: user?.displayName ?? 'Usuario',
            ),
            const SizedBox(height: 16),
            _buildField(
              icon: Icons.email,
              iconColor: azulElectrico,
              label: 'Correo electrónico',
              value: user?.email ?? 'correo@ejemplo.com',
            ),
            const SizedBox(height: 16),
            _buildField(
              icon: Icons.calendar_today,
              iconColor: Colors.teal,
              label: 'Fecha de inscripción',
              value: creationDate,
            ),
            const SizedBox(height: 16),
            _buildField(
              icon: Icons.access_time_filled,
              iconColor: verde,
              label: 'Último acceso',
              value: lastSignIn,
            ),
            const SizedBox(height: 16),

            // Número de identidad desde Firestore
            if (user != null)
              FutureBuilder<String>(
                future: _getNumeroIdentidad(user.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildField(
                      icon: Icons.badge,
                      iconColor: naranjaFuerte,
                      label: 'Número de identidad',
                      value: 'Cargando...',
                    );
                  } else if (snapshot.hasError) {
                    return _buildField(
                      icon: Icons.error,
                      iconColor: Colors.red,
                      label: 'Número de identidad',
                      value: 'Error al cargar',
                    );
                  } else {
                    return _buildField(
                      icon: Icons.badge,
                      iconColor: naranjaFuerte,
                      label: 'Número de identidad',
                      value: snapshot.data ?? 'No registrado',
                    );
                  }
                },
              ),

            const SizedBox(height: 16),

            _buildField(
              icon: Icons.security,
              iconColor: Colors.redAccent,
              label: 'Estado de cuenta',
              value: user != null ? 'Activa' : 'Inactiva',
            ),

            const SizedBox(height: 40),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: azulElectrico,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                // Cerrar sesión
                await FirebaseAuth.instance.signOut();

                // Redirigir al login
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginUsersPage()),
                );
              },
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text('Cerrar sesión', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black54)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 16, color: Colors.black87)),
            ],
          ),
        ),
      ],
    );
  }
}