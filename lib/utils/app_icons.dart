import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppIcons {
  static const String arrowDown = '''
  <svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M10.6733 8.56668L8.92664 10.3133C8.4133 10.8267 7.5733 10.8267 7.05997 10.3133L2.71997 5.96667M13.28 5.96667L12.5866 6.66001" stroke="#272727" stroke-width="1.5" stroke-miterlimit="10" stroke-linecap="round" stroke-linejoin="round"/>
  </svg>
  ''';

  static const String bag = '''
  <svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M4.99988 5.11336V4.4667C4.99988 2.9667 6.20655 1.49336 7.70655 1.35336..." stroke="currentColor" stroke-width="1.5" stroke-miterlimit="10" stroke-linecap="round" stroke-linejoin="round"/>
  </svg>
  ''';

  static const String search = '''
  <svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M7.66658 1.33337C11.1666 1.33337 13.9999 4.16671 13.9999 7.66671C13.9999 11.1667 11.1666 14 7.66658 14..." stroke="#272727" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  </svg>
  ''';

  static const String cart = '''
  <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M6 6H21L20 10H7L6 6ZM7 10L6 18H20L21 10H7ZM9 21C8.44772 21 8 20.5523 8 20C8 19.4477 8.44772 19 9 19C9.55228 19 10 19.4477 10 20C10 20.5523 9.55228 21 9 21ZM17 21C16.4477 21 16 20.5523 16 20C16 19.4477 16.4477 19 17 19C17.5523 19 18 19.4477 18 20C18 20.5523 17.5523 21 17 21Z" 
      stroke="#272727" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  </svg>
  ''';

  static Widget home = SvgPicture.string(
    '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path d="M22 10.498C22 9.28803 21.19 7.73803 20.2 7.04803L14.02 2.71803C12.62 1.73803 10.37 1.78803 9.02 2.83803..." stroke="#272727" stroke-opacity="0.5" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
    </svg>''',
    width: 24,
    height: 24,
  );

  static Widget notification = SvgPicture.string(
    '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path d="M12.6667 6.441V9.771M21.2567 15.17C21.9867 16.39 21.4067 17.97 20.0567 18.42..." stroke="#272727" stroke-opacity="0.5" stroke-width="1.5" stroke-miterlimit="10" stroke-linecap="round"/>
    </svg>''',
    width: 24,
    height: 24,
  );

  static Widget receipt = SvgPicture.string(
    '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path d="M20.5 7.04C20.5 3.01 19.56 2 15.78 2H8.22C4.44 2 3.5 3.01 3.5 7.04..." stroke="#FA3636" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
    </svg>''',
    width: 24,
    height: 24,
  );

  static Widget profile = SvgPicture.string(
    '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path d="M15.68 3.96C16.16 4.67 16.44 5.52 16.44 6.44C16.43 8.84 14.54 10.79 12.16 10.87..." stroke="#272727" stroke-opacity="0.5" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
    </svg>''',
    width: 24,
    height: 24,
  );

  static Widget arrowRight = SvgPicture.string(
    '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path d="M12.9 7.94001L15.52 10.56C16.29 11.33 16.29 12.59 15.52 13.36L9 19.87M9 4.04001L10.04 5.08001" stroke="#272727" stroke-width="1.5" stroke-miterlimit="10" stroke-linecap="round" stroke-linejoin="round"/>
    </svg>''',
    width: 24,
    height: 24,
  );

  static Widget heart = SvgPicture.string(
    '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path d="M12 21C-8 8 6-3 12 5C18-3 32 8 12 21Z" stroke="#FF0000" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
    </svg>''',
    width: 24,
    height: 24,
  );
}
