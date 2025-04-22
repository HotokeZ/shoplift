import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NotificationIcons {
  static Widget get bell => SvgPicture.string(
    '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path d="M12.0001 6.441V9.771M20.5901 15.17C21.3201 16.39 20.7401 17.97 19.3901 18.42C14.6088 20.01 9.44134 20.01 4.66005 18.42C3.22005 17.94 2.67005 16.48 3.46005 15.17L4.73005 13.05C5.08005 12.47 5.36005 11.44 5.36005 10.77V8.67C5.35874 7.79456 5.53004 6.92744 5.86414 6.11826C6.19825 5.30907 6.68862 4.5737 7.30718 3.9542C7.92575 3.33471 8.66039 2.84324 9.46907 2.50792C10.2778 2.1726 11.1446 2 12.0201 2C15.6801 2 18.6801 5 18.6801 8.66V10.76C18.6801 10.94 18.7001 11.14 18.7301 11.35" stroke="#272727" stroke-width="1.5" stroke-miterlimit="10" stroke-linecap="round"/>
      <path d="M15.33 18.82C15.33 20.65 13.83 22.15 12 22.15C11.09 22.15 10.25 21.77 9.65004 21.17C9.05004 20.57 8.67004 19.73 8.67004 18.82" stroke="#272727" stroke-width="1.5" stroke-miterlimit="10"/>
      <circle cx="19" cy="5" r="4" fill="#FA3636"/>
    </svg>''',
  );

  static Widget get home => SvgPicture.string(
    '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path d="M22 10.498C22 9.28803 21.19 7.73803 20.2 7.04803L14.02 2.71803C12.62 1.73803 10.37 1.78803 9.02 2.83803L3.63 7.03803C2.73 7.73803 2 9.22803 2 10.358V17.768C2 20.088 3.89 21.988 6.21 21.988H17.79C20.11 21.988 22 20.088 22 17.778V14.678M12 17.988V14.988" stroke="#272727" stroke-opacity="0.5" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
    </svg>''',
  );

  static Widget get notification => SvgPicture.string(
    '''<svg width="25" height="24" viewBox="0 0 25 24" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path d="M12.6667 6.441V9.771M21.2567 15.17C21.9867 16.39 21.4067 17.97 20.0567 18.42C15.2754 20.01 10.108 20.01 5.32668 18.42C3.88668 17.94 3.33668 16.48 4.12668 15.17L5.39668 13.05C5.74668 12.47 6.02668 11.44 6.02668 10.77V8.67C6.02537 7.79456 6.19666 6.92744 6.53077 6.11826C6.86488 5.30907 7.35524 4.5737 7.97381 3.9542C8.59238 3.33471 9.32702 2.84324 10.1357 2.50792C10.9444 2.1726 11.8112 2 12.6867 2C16.3467 2 19.3467 5 19.3467 8.66V10.76C19.3467 10.94 19.3667 11.14 19.3967 11.35" stroke="#FA3636" stroke-width="1.5" stroke-miterlimit="10" stroke-linecap="round"/>
      <path d="M15.9967 18.82C15.9967 20.65 14.4967 22.15 12.6667 22.15C11.7567 22.15 10.9167 21.77 10.3167 21.17C9.71667 20.57 9.33667 19.73 9.33667 18.82" stroke="#FA3636" stroke-width="1.5" stroke-miterlimit="10"/>
    </svg>''',
  );

  static Widget get receipt => SvgPicture.string(
    '''<svg width="25" height="24" viewBox="0 0 25 24" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path d="M20.8334 7.04C20.8334 3.01 19.8934 2 16.1134 2H8.55337C4.77337 2 3.83337 3.01 3.83337 7.04V18.3C3.83337 20.96 5.29337 21.59 7.06337 19.69L7.07337 19.68C7.89337 18.81 9.14337 18.88 9.85337 19.83L10.8634 21.18C11.6734 22.25 12.9834 22.25 13.7934 21.18L14.8034 19.83C15.5234 18.87 16.7734 18.8 17.5934 19.68C19.3734 21.58 20.8234 20.95 20.8234 18.29V11M8.33337 7H16.3334M9.33337 11H15.3334" stroke="#272727" stroke-opacity="0.5" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
    </svg>''',
  );

  static Widget get profile => SvgPicture.string(
    '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path d="M15.68 3.96C16.16 4.67 16.4401 5.52 16.4401 6.44C16.4301 8.84 14.54 10.79 12.16 10.87C12.06 10.86 11.94 10.86 11.83 10.87C9.62005 10.8 7.83005 9.11 7.59005 6.95C7.30005 4.38 9.41005 2 11.99 2M6.99005 14.56C4.57005 16.18 4.57005 18.82 6.99005 20.43C9.74005 22.27 14.25 22.27 17 20.43C19.42 18.81 19.42 16.17 17 14.56C14.27 12.73 9.76005 12.73 6.99005 14.56Z" stroke="#272727" stroke-opacity="0.5" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
    </svg>''',
  );
}