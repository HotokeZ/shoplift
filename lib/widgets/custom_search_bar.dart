import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomSearchBar extends StatelessWidget {
  final String searchText;
  final VoidCallback onBackPressed;
  final VoidCallback onClearPressed;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onSubmitted; // Added onSubmitted callback

  const CustomSearchBar({
    Key? key,
    required this.searchText,
    required this.onBackPressed,
    required this.onClearPressed,
    required this.onSearchChanged,
    required this.onSubmitted, // Added onSubmitted parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 800),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          MediaQuery.of(context).size.width > 991
              ? const SizedBox()
              : Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F4F4),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: IconButton(
                    icon: SvgPicture.string(
                      '''<svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <path d="M7.46004 5.29336L5.71337 7.04003C5.20004 7.55336 5.20004 8.39336 5.71337 8.90669L10.06 13.2534M10.06 2.69336L9.3667 3.38669"
                        stroke="#272727" stroke-width="1.5" stroke-miterlimit="10" stroke-linecap="round" stroke-linejoin="round"/>
                      </svg>''',
                      width: 16,
                      height: 16,
                    ),
                    onPressed: onBackPressed,
                    tooltip: 'Back',
                  ),
                ),
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F4F4),
                borderRadius: BorderRadius.circular(100),
              ),
              padding: const EdgeInsets.fromLTRB(19, 10, 11, 11),
              child: Row(
                children: [
                  SvgPicture.string(
                    '''<svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
                      <g clip-path="url(#clip0_7_593)">
                        <path d="M7.66671 1.33337C11.1667 1.33337 14 4.16671 14 7.66671C14 11.1667 11.1667 14 7.66671 14C4.16671 14 1.33337 11.1667 1.33337 7.66671C1.33337 5.20004 2.74004 3.06671 4.80004 2.02004M14.6667 14.6667L13.3334 13.3334"
                        stroke="#272727" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
                      </g>
                    </svg>''',
                    width: 16,
                    height: 16,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(text: searchText),
                      onChanged: onSearchChanged,
                      onSubmitted: onSubmitted, // Trigger onSubmitted when Enter is pressed
                      decoration: const InputDecoration(
                        hintText: 'Search',
                        hintStyle: TextStyle(
                          color: Color(0xFF272727),
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 1.6,
                        ),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(
                        color: Color(0xFF272727),
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 1.6,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: SvgPicture.string(
                      '''<svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <path d="M12 4L4 12M4 4L12 12" stroke="#272727" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                      </svg>''',
                      width: 16,
                      height: 16,
                    ),
                    onPressed: onClearPressed,
                    tooltip: 'Clear search',
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}