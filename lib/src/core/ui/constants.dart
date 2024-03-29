import 'package:flutter/material.dart';

/*Como nosso app terá uma paleta de cores especifica, entao vamos defini-las logo
 num outro arquivo, seguindo a mesma ideia desse arquivo de Theme, porem dessa vez é para Constants. */
sealed class ColorsConstants {
  static const brown = Color(0xFFB07B01);
  static const grey = Color(0xFF999999);
  static const greyLight = Color(0xFFE6E2E9);
  static const red = Color(0xFFEB1212);
}

sealed class FontConstants {
  static const fontFamily = 'Poppins';
}

sealed class ImageConstants {
  static const backgroundChair = 'assets/images/background_image_chair.jpg';
  static const imageLogo = 'assets/images/imgLogo.png';
  static const avatar = 'assets/images/avatar.png';
}
