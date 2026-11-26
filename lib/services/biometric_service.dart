import 'package:vonto_biometric/vonto_biometric.dart';

class BiometricService {
  final VontoBiometric biometric = VontoBiometric();
  Future<bool> checkBiometric() async {
    try {
      final availability = await biometric.checkAvailability(
        biometricStrength: BiometricStrength.strong,
        allowDeviceCredential: false,
      );
      if (availability== true) {
        print('Available');
      }
      return availability == BiometricAvailability.available;

    } catch (e) {
      print('Biometric availability error:$e');
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      bool available = await checkBiometric();
      if (!available) 
        return false;
      
      final result = await biometric.authenticate(
        title: 'InstaBee Authentication',
        subtitle:'Vertify your fingerprint to continue',
      
        allowDeviceCredential: true
      );
      return result.isAuthenticated;
    } catch (e) {
      print('Biometric authentication error:$e');
      return false;
    }
  }
}
