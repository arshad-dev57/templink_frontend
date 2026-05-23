import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:templink/Controllers/register_controller.dart';
import 'package:templink/Employee/Screens/Employee_Profile_Complete_Screen.dart';
import 'package:templink/Employeer/Screens/Employeer_profile_complete_screen.dart';
import 'package:templink/Global_Screens/login_screen.dart';
import 'package:templink/Utils/colors.dart';
import 'package:templink/Utils/responsive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  final bool isCompany;
  const RegisterScreen({super.key, required this.isCompany});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final RegisterController controller =
      Get.put(RegisterController(), permanent: true);

  final _formKey = GlobalKey<FormState>();
  bool _agreed = false;
  bool _sendEmails = false;
  bool _showPassword = false;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Country selection variables
  String _selectedCountry = '';
  List<CountryModel> _countries = [];
  bool _isLoadingCountries = false;
  bool _hasError = false;

  static const Color kGreen = primary;

  @override
  void initState() {
    super.initState();
    _fetchAllCountries();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Fetch ALL countries from API (250+ countries)
  Future<void> _fetchAllCountries() async {
    setState(() {
      _isLoadingCountries = true;
      _hasError = false;
    });
    
    try {
      // Using restcountries.com API - gives all 250+ countries
      final response = await http.get(
        Uri.parse('https://restcountries.com/v3.1/all?fields=name,cca2,flags'),
        headers: {
          'User-Agent': 'Mozilla/5.0',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<CountryModel> countries = [];
        
        for (var item in data) {
          String name = item['name']['common'] ?? 'Unknown';
          String code = item['cca2']?.toString().toLowerCase() ?? '';
          String flagUrl = code.isNotEmpty 
              ? 'https://flagcdn.com/w40/$code.png' 
              : '';
          
          countries.add(CountryModel(
            name: name,
            code: code,
            flagUrl: flagUrl,
          ));
        }
        
        // Sort alphabetically
        countries.sort((a, b) => a.name.compareTo(b.name));
        
        print('✅ Total countries fetched: ${countries.length}'); // Should show 250+
        
        setState(() {
          _countries = countries;
          // Set default country (optional)
          _selectedCountry = countries.isNotEmpty ? countries[0].name : '';
          _isLoadingCountries = false;
        });
      } else {
        _useFallbackCountries();
      }
    } catch (e) {
      print('❌ Error fetching countries: $e');
      _useFallbackCountries();
    }
  }

  void _useFallbackCountries() {
    setState(() {
      _countries = _getFallbackCountriesList();
      _selectedCountry = _countries.isNotEmpty ? _countries[0].name : '';
      _isLoadingCountries = false;
      _hasError = true;
    });
  }

  List<CountryModel> _getFallbackCountriesList() {
    return [
      CountryModel(name: 'United States', code: 'us', flagUrl: 'https://flagcdn.com/w40/us.png'),
      CountryModel(name: 'United Kingdom', code: 'gb', flagUrl: 'https://flagcdn.com/w40/gb.png'),
      CountryModel(name: 'Canada', code: 'ca', flagUrl: 'https://flagcdn.com/w40/ca.png'),
      CountryModel(name: 'Australia', code: 'au', flagUrl: 'https://flagcdn.com/w40/au.png'),
      CountryModel(name: 'India', code: 'in', flagUrl: 'https://flagcdn.com/w40/in.png'),
      CountryModel(name: 'Germany', code: 'de', flagUrl: 'https://flagcdn.com/w40/de.png'),
      CountryModel(name: 'France', code: 'fr', flagUrl: 'https://flagcdn.com/w40/fr.png'),
      CountryModel(name: 'UAE', code: 'ae', flagUrl: 'https://flagcdn.com/w40/ae.png'),
      CountryModel(name: 'Saudi Arabia', code: 'sa', flagUrl: 'https://flagcdn.com/w40/sa.png'),
      CountryModel(name: 'Pakistan', code: 'pk', flagUrl: 'https://flagcdn.com/w40/pk.png'),
      CountryModel(name: 'Bangladesh', code: 'bd', flagUrl: 'https://flagcdn.com/w40/bd.png'),
      CountryModel(name: 'Sri Lanka', code: 'lk', flagUrl: 'https://flagcdn.com/w40/lk.png'),
      CountryModel(name: 'Nepal', code: 'np', flagUrl: 'https://flagcdn.com/w40/np.png'),
      CountryModel(name: 'Malaysia', code: 'my', flagUrl: 'https://flagcdn.com/w40/my.png'),
      CountryModel(name: 'Singapore', code: 'sg', flagUrl: 'https://flagcdn.com/w40/sg.png'),
      CountryModel(name: 'China', code: 'cn', flagUrl: 'https://flagcdn.com/w40/cn.png'),
      CountryModel(name: 'Japan', code: 'jp', flagUrl: 'https://flagcdn.com/w40/jp.png'),
      CountryModel(name: 'South Korea', code: 'kr', flagUrl: 'https://flagcdn.com/w40/kr.png'),
      CountryModel(name: 'Brazil', code: 'br', flagUrl: 'https://flagcdn.com/w40/br.png'),
      CountryModel(name: 'Mexico', code: 'mx', flagUrl: 'https://flagcdn.com/w40/mx.png'),
      CountryModel(name: 'South Africa', code: 'za', flagUrl: 'https://flagcdn.com/w40/za.png'),
      CountryModel(name: 'Nigeria', code: 'ng', flagUrl: 'https://flagcdn.com/w40/ng.png'),
      CountryModel(name: 'Egypt', code: 'eg', flagUrl: 'https://flagcdn.com/w40/eg.png'),
      CountryModel(name: 'Turkey', code: 'tr', flagUrl: 'https://flagcdn.com/w40/tr.png'),
      CountryModel(name: 'Russia', code: 'ru', flagUrl: 'https://flagcdn.com/w40/ru.png'),
      CountryModel(name: 'Italy', code: 'it', flagUrl: 'https://flagcdn.com/w40/it.png'),
      CountryModel(name: 'Spain', code: 'es', flagUrl: 'https://flagcdn.com/w40/es.png'),
      CountryModel(name: 'Netherlands', code: 'nl', flagUrl: 'https://flagcdn.com/w40/nl.png'),
      CountryModel(name: 'Sweden', code: 'se', flagUrl: 'https://flagcdn.com/w40/se.png'),
      CountryModel(name: 'Norway', code: 'no', flagUrl: 'https://flagcdn.com/w40/no.png'),
      CountryModel(name: 'Denmark', code: 'dk', flagUrl: 'https://flagcdn.com/w40/dk.png'),
      CountryModel(name: 'Finland', code: 'fi', flagUrl: 'https://flagcdn.com/w40/fi.png'),
      CountryModel(name: 'Poland', code: 'pl', flagUrl: 'https://flagcdn.com/w40/pl.png'),
      CountryModel(name: 'Greece', code: 'gr', flagUrl: 'https://flagcdn.com/w40/gr.png'),
      CountryModel(name: 'Portugal', code: 'pt', flagUrl: 'https://flagcdn.com/w40/pt.png'),
      CountryModel(name: 'Ireland', code: 'ie', flagUrl: 'https://flagcdn.com/w40/ie.png'),
      CountryModel(name: 'Belgium', code: 'be', flagUrl: 'https://flagcdn.com/w40/be.png'),
      CountryModel(name: 'Switzerland', code: 'ch', flagUrl: 'https://flagcdn.com/w40/ch.png'),
      CountryModel(name: 'Austria', code: 'at', flagUrl: 'https://flagcdn.com/w40/at.png'),
      CountryModel(name: 'Indonesia', code: 'id', flagUrl: 'https://flagcdn.com/w40/id.png'),
      CountryModel(name: 'Philippines', code: 'ph', flagUrl: 'https://flagcdn.com/w40/ph.png'),
      CountryModel(name: 'Vietnam', code: 'vn', flagUrl: 'https://flagcdn.com/w40/vn.png'),
      CountryModel(name: 'Thailand', code: 'th', flagUrl: 'https://flagcdn.com/w40/th.png'),
      CountryModel(name: 'Israel', code: 'il', flagUrl: 'https://flagcdn.com/w40/il.png'),
      CountryModel(name: 'Kenya', code: 'ke', flagUrl: 'https://flagcdn.com/w40/ke.png'),
      CountryModel(name: 'Argentina', code: 'ar', flagUrl: 'https://flagcdn.com/w40/ar.png'),
      CountryModel(name: 'Chile', code: 'cl', flagUrl: 'https://flagcdn.com/w40/cl.png'),
      CountryModel(name: 'Colombia', code: 'co', flagUrl: 'https://flagcdn.com/w40/co.png'),
      CountryModel(name: 'Peru', code: 'pe', flagUrl: 'https://flagcdn.com/w40/pe.png'),
      CountryModel(name: 'Venezuela', code: 've', flagUrl: 'https://flagcdn.com/w40/ve.png'),
      CountryModel(name: 'Morocco', code: 'ma', flagUrl: 'https://flagcdn.com/w40/ma.png'),
      CountryModel(name: 'Algeria', code: 'dz', flagUrl: 'https://flagcdn.com/w40/dz.png'),
      CountryModel(name: 'Tunisia', code: 'tn', flagUrl: 'https://flagcdn.com/w40/tn.png'),
      CountryModel(name: 'Libya', code: 'ly', flagUrl: 'https://flagcdn.com/w40/ly.png'),
      CountryModel(name: 'Sudan', code: 'sd', flagUrl: 'https://flagcdn.com/w40/sd.png'),
      CountryModel(name: 'Ethiopia', code: 'et', flagUrl: 'https://flagcdn.com/w40/et.png'),
      CountryModel(name: 'Somalia', code: 'so', flagUrl: 'https://flagcdn.com/w40/so.png'),
      CountryModel(name: 'Ghana', code: 'gh', flagUrl: 'https://flagcdn.com/w40/gh.png'),
      CountryModel(name: 'Ivory Coast', code: 'ci', flagUrl: 'https://flagcdn.com/w40/ci.png'),
      CountryModel(name: 'Cameroon', code: 'cm', flagUrl: 'https://flagcdn.com/w40/cm.png'),
      CountryModel(name: 'Uganda', code: 'ug', flagUrl: 'https://flagcdn.com/w40/ug.png'),
      CountryModel(name: 'Tanzania', code: 'tz', flagUrl: 'https://flagcdn.com/w40/tz.png'),
      CountryModel(name: 'Mozambique', code: 'mz', flagUrl: 'https://flagcdn.com/w40/mz.png'),
      CountryModel(name: 'Angola', code: 'ao', flagUrl: 'https://flagcdn.com/w40/ao.png'),
      CountryModel(name: 'Zimbabwe', code: 'zw', flagUrl: 'https://flagcdn.com/w40/zw.png'),
      CountryModel(name: 'Zambia', code: 'zm', flagUrl: 'https://flagcdn.com/w40/zm.png'),
      CountryModel(name: 'Malawi', code: 'mw', flagUrl: 'https://flagcdn.com/w40/mw.png'),
      CountryModel(name: 'Botswana', code: 'bw', flagUrl: 'https://flagcdn.com/w40/bw.png'),
      CountryModel(name: 'Namibia', code: 'na', flagUrl: 'https://flagcdn.com/w40/na.png'),
      CountryModel(name: 'Mauritius', code: 'mu', flagUrl: 'https://flagcdn.com/w40/mu.png'),
      CountryModel(name: 'Fiji', code: 'fj', flagUrl: 'https://flagcdn.com/w40/fj.png'),
      CountryModel(name: 'Papua New Guinea', code: 'pg', flagUrl: 'https://flagcdn.com/w40/pg.png'),
      CountryModel(name: 'New Zealand', code: 'nz', flagUrl: 'https://flagcdn.com/w40/nz.png'),
      CountryModel(name: 'Iceland', code: 'is', flagUrl: 'https://flagcdn.com/w40/is.png'),
      CountryModel(name: 'Greenland', code: 'gl', flagUrl: 'https://flagcdn.com/w40/gl.png'),
      CountryModel(name: 'Cuba', code: 'cu', flagUrl: 'https://flagcdn.com/w40/cu.png'),
      CountryModel(name: 'Jamaica', code: 'jm', flagUrl: 'https://flagcdn.com/w40/jm.png'),
      CountryModel(name: 'Haiti', code: 'ht', flagUrl: 'https://flagcdn.com/w40/ht.png'),
      CountryModel(name: 'Dominican Republic', code: 'do', flagUrl: 'https://flagcdn.com/w40/do.png'),
      CountryModel(name: 'Puerto Rico', code: 'pr', flagUrl: 'https://flagcdn.com/w40/pr.png'),
      CountryModel(name: 'Bahamas', code: 'bs', flagUrl: 'https://flagcdn.com/w40/bs.png'),
      CountryModel(name: 'Barbados', code: 'bb', flagUrl: 'https://flagcdn.com/w40/bb.png'),
      CountryModel(name: 'Trinidad and Tobago', code: 'tt', flagUrl: 'https://flagcdn.com/w40/tt.png'),
      CountryModel(name: 'Guyana', code: 'gy', flagUrl: 'https://flagcdn.com/w40/gy.png'),
      CountryModel(name: 'Suriname', code: 'sr', flagUrl: 'https://flagcdn.com/w40/sr.png'),
      CountryModel(name: 'Ecuador', code: 'ec', flagUrl: 'https://flagcdn.com/w40/ec.png'),
      CountryModel(name: 'Bolivia', code: 'bo', flagUrl: 'https://flagcdn.com/w40/bo.png'),
      CountryModel(name: 'Paraguay', code: 'py', flagUrl: 'https://flagcdn.com/w40/py.png'),
      CountryModel(name: 'Uruguay', code: 'uy', flagUrl: 'https://flagcdn.com/w40/uy.png'),
      CountryModel(name: 'Costa Rica', code: 'cr', flagUrl: 'https://flagcdn.com/w40/cr.png'),
      CountryModel(name: 'Panama', code: 'pa', flagUrl: 'https://flagcdn.com/w40/pa.png'),
      CountryModel(name: 'Guatemala', code: 'gt', flagUrl: 'https://flagcdn.com/w40/gt.png'),
      CountryModel(name: 'Honduras', code: 'hn', flagUrl: 'https://flagcdn.com/w40/hn.png'),
      CountryModel(name: 'El Salvador', code: 'sv', flagUrl: 'https://flagcdn.com/w40/sv.png'),
      CountryModel(name: 'Nicaragua', code: 'ni', flagUrl: 'https://flagcdn.com/w40/ni.png'),
      CountryModel(name: 'Belize', code: 'bz', flagUrl: 'https://flagcdn.com/w40/bz.png'),
      CountryModel(name: 'Mongolia', code: 'mn', flagUrl: 'https://flagcdn.com/w40/mn.png'),
      CountryModel(name: 'Kazakhstan', code: 'kz', flagUrl: 'https://flagcdn.com/w40/kz.png'),
      CountryModel(name: 'Uzbekistan', code: 'uz', flagUrl: 'https://flagcdn.com/w40/uz.png'),
      CountryModel(name: 'Turkmenistan', code: 'tm', flagUrl: 'https://flagcdn.com/w40/tm.png'),
      CountryModel(name: 'Kyrgyzstan', code: 'kg', flagUrl: 'https://flagcdn.com/w40/kg.png'),
      CountryModel(name: 'Tajikistan', code: 'tj', flagUrl: 'https://flagcdn.com/w40/tj.png'),
      CountryModel(name: 'Afghanistan', code: 'af', flagUrl: 'https://flagcdn.com/w40/af.png'),
      CountryModel(name: 'Iran', code: 'ir', flagUrl: 'https://flagcdn.com/w40/ir.png'),
      CountryModel(name: 'Iraq', code: 'iq', flagUrl: 'https://flagcdn.com/w40/iq.png'),
      CountryModel(name: 'Syria', code: 'sy', flagUrl: 'https://flagcdn.com/w40/sy.png'),
      CountryModel(name: 'Jordan', code: 'jo', flagUrl: 'https://flagcdn.com/w40/jo.png'),
      CountryModel(name: 'Lebanon', code: 'lb', flagUrl: 'https://flagcdn.com/w40/lb.png'),
      CountryModel(name: 'Palestine', code: 'ps', flagUrl: 'https://flagcdn.com/w40/ps.png'),
      CountryModel(name: 'Yemen', code: 'ye', flagUrl: 'https://flagcdn.com/w40/ye.png'),
      CountryModel(name: 'Oman', code: 'om', flagUrl: 'https://flagcdn.com/w40/om.png'),
      CountryModel(name: 'Kuwait', code: 'kw', flagUrl: 'https://flagcdn.com/w40/kw.png'),
      CountryModel(name: 'Qatar', code: 'qa', flagUrl: 'https://flagcdn.com/w40/qa.png'),
      CountryModel(name: 'Bahrain', code: 'bh', flagUrl: 'https://flagcdn.com/w40/bh.png'),
      CountryModel(name: 'Afghanistan', code: 'af', flagUrl: 'https://flagcdn.com/w40/af.png'),
    ];
  }

  InputDecoration _decoration({
    required String hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    final isDesktop = Responsive.isDesktop(context);
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: isDesktop ? 14.0 : 14.sp,
        color: Colors.grey.shade500,
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 12.0 : 16.w,
        vertical: isDesktop ? 10.0 : 14.h,
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      errorMaxLines: 2,
      helperText: ' ',
      isDense: true,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(isDesktop ? 8.0 : 8.r),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(isDesktop ? 8.0 : 8.r),
        borderSide: BorderSide(color: kGreen, width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(isDesktop ? 8.0 : 8.r),
        borderSide: const BorderSide(color: Colors.red, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(isDesktop ? 8.0 : 8.r),
        borderSide: const BorderSide(color: Colors.red, width: 1.2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (isDesktop) {
            return Row(
              children: [
                Expanded(
                  flex: 1,
                  child: _buildFormContent(isDesktop: true),
                ),
                Expanded(
                  flex: 1,
                  child: _buildImageSection(),
                ),
              ],
            );
          } else if (isTablet) {
            return Row(
              children: [
                Expanded(
                  flex: 6,
                  child: _buildFormContent(isDesktop: false),
                ),
                Expanded(
                  flex: 4,
                  child: _buildImageSection(),
                ),
              ],
            );
          } else {
            return _buildFormContent(isDesktop: false);
          }
        },
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4CAF50),
            Color(0xFF2E7D32),
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          FutureBuilder(
            future: _precacheImage(),
            builder: (context, snapshot) {
              return Image.network(
                'https://images.unsplash.com/photo-1521737711867-e3b97375f902?w=800&h=1200&fit=crop',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFF4CAF50),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.work_outline,
                            size: 80.sp,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Templink',
                            style: TextStyle(
                              fontSize: 32.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                },
              );
            },
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.6),
                ],
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.responsive(
                          context: context,
                          mobile: 20.w,
                          tablet: 30.w,
                          desktop: 40.w,
                        ),
                        vertical: Responsive.responsive(
                          context: context,
                          mobile: 20.h,
                          tablet: 30.h,
                          desktop: 40.h,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.work_outline,
                            size: Responsive.responsive(
                              context: context,
                              mobile: 60.sp,
                              tablet: 70.sp,
                              desktop: 80.sp,
                            ),
                            color: Colors.white,
                          ),
                          SizedBox(
                              height: Responsive.responsive(
                            context: context,
                            mobile: 16.h,
                            tablet: 20.h,
                            desktop: 24.h,
                          )),
                          Text(
                            'Join the Future of Work',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: Responsive.responsive(
                                context: context,
                                mobile: 24.sp,
                                tablet: 30.sp,
                                desktop: 36.sp,
                              ),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                            ),
                            softWrap: true,
                            overflow: TextOverflow.visible,
                          ),
                          SizedBox(
                              height: Responsive.responsive(
                            context: context,
                            mobile: 12.h,
                            tablet: 14.h,
                            desktop: 16.h,
                          )),
                          Text(
                            widget.isCompany
                                ? 'Find the best talent for your company'
                                : 'Discover amazing job opportunities',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: Responsive.responsive(
                                context: context,
                                mobile: 14.sp,
                                tablet: 16.sp,
                                desktop: 18.sp,
                              ),
                              color: Colors.white.withOpacity(0.9),
                              height: 1.4,
                            ),
                            softWrap: true,
                            overflow: TextOverflow.visible,
                          ),
                          SizedBox(
                              height: Responsive.responsive(
                            context: context,
                            mobile: 24.h,
                            tablet: 28.h,
                            desktop: 32.h,
                          )),
                          _buildResponsiveFeatureItem(
                              Icons.verified_outlined, 'Verified Professionals'),
                          SizedBox(
                              height: Responsive.responsive(
                            context: context,
                            mobile: 12.h,
                            tablet: 14.h,
                            desktop: 16.h,
                          )),
                          _buildResponsiveFeatureItem(Icons.security_outlined,
                              'Secure & Trusted Platform'),
                          SizedBox(
                              height: Responsive.responsive(
                            context: context,
                            mobile: 12.h,
                            tablet: 14.h,
                            desktop: 16.h,
                          )),
                          _buildResponsiveFeatureItem(
                              Icons.support_agent_outlined,
                              '24/7 Customer Support'),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveFeatureItem(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: Responsive.responsive(
            context: context,
            mobile: 20.sp,
            tablet: 22.sp,
            desktop: 24.sp,
          ),
        ),
        SizedBox(
            width: Responsive.responsive(
          context: context,
          mobile: 10.w,
          tablet: 11.w,
          desktop: 12.w,
        )),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: Responsive.responsive(
                context: context,
                mobile: 13.sp,
                tablet: 14.sp,
                desktop: 16.sp,
              ),
              color: Colors.white.withOpacity(0.95),
              height: 1.3,
            ),
            softWrap: true,
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    );
  }

  Future<void> _precacheImage() async {
    await precacheImage(
      const NetworkImage(
          'https://images.unsplash.com/photo-1521737711867-e3b97375f902?w=800&h=1200&fit=crop'),
      context,
    );
  }

  Widget _buildFormContent({required bool isDesktop}) {
    final maxWidth = isDesktop
        ? 480.0
        : (Responsive.isTablet(context) ? 500.w : double.infinity);

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop
              ? 40.0
              : (Responsive.isTablet(context) ? 32.w : 20.w),
          vertical: isDesktop ? 40.0 : 20.h,
        ),
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Templink',
                    style: TextStyle(
                      fontSize: isDesktop ? 36.0 : 32.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: isDesktop ? 12.0 : 8.h),
                  Text(
                    isDesktop
                        ? 'Create your account to get started'
                        : 'Sign up to find work you love',
                    style: TextStyle(
                      fontSize: isDesktop ? 16.0 : 14.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: isDesktop ? 32.0 : 24.h),

                  // First & Last Name Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'First name',
                          controller: _firstNameController,
                          isDesktop: isDesktop,
                          validator: (value) =>
                              (value == null || value.isEmpty)
                                  ? 'First name is required'
                                  : null,
                        ),
                      ),
                      SizedBox(width: isDesktop ? 16.0 : 16.w),
                      Expanded(
                        child: _buildTextField(
                          label: 'Last name',
                          controller: _lastNameController,
                          isDesktop: isDesktop,
                          validator: (value) =>
                              (value == null || value.isEmpty)
                                  ? 'Last name is required'
                                  : null,
                        ),
                      ),
                    ],
                  ),

                  // Email Field
                  _buildTextField(
                    label: 'Email',
                    controller: _emailController,
                    isDesktop: isDesktop,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Email is required';
                      if (!GetUtils.isEmail(value))
                        return 'Enter a valid email';
                      return null;
                    },
                  ),

                  // Password Field
                  _buildPasswordField(isDesktop: isDesktop),

                  // Country Dropdown with Search - ALL COUNTRIES WILL SHOW
                  _buildSearchableCountryDropdown(isDesktop: isDesktop),

                  // Send Emails Checkbox
                  Row(
                    children: [
                      Transform.scale(
                        scale: 0.9,
                        child: Checkbox(
                          value: _sendEmails,
                          onChanged: (value) =>
                              setState(() => _sendEmails = value ?? false),
                          activeColor: kGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(isDesktop ? 4.0 : 4.r),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Send me helpful emails to find rewarding work and job leads.',
                          style: TextStyle(
                            fontSize: isDesktop ? 12.0 : 13.sp,
                            color: Colors.grey.shade700,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Terms & Conditions Checkbox
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Transform.scale(
                        scale: 0.9,
                        child: Checkbox(
                          value: _agreed,
                          onChanged: (value) =>
                              setState(() => _agreed = value ?? false),
                          activeColor: kGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(isDesktop ? 4.0 : 4.r),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding:
                              EdgeInsets.only(top: isDesktop ? 4.0 : 8.h),
                          child: RichText(
                            text: TextSpan(
                              text: 'Yes, I understand and agree to the ',
                              style: TextStyle(
                                fontSize: isDesktop ? 11.0 : 12.sp,
                                color: Colors.grey.shade700,
                                height: 1.4,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: TextStyle(
                                    color: kGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const TextSpan(text: ', '),
                                TextSpan(
                                  text: 'User Agreement',
                                  style: TextStyle(
                                    color: kGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(
                                    color: kGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: isDesktop ? 32.0 : 24.h),

                  // Submit Button
                  Obx(() {
                    final loading = controller.isLoading.value;
                    return SizedBox(
                      width: double.infinity,
                      height: isDesktop ? 44.0 : 48.h,
                      child: ElevatedButton(
                        onPressed: loading
                            ? null
                            : () async {
                                if (!_formKey.currentState!.validate()) return;
                                if (!_agreed) {
                                  Get.snackbar(
                                    "Error",
                                    "Please accept terms and conditions",
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                    snackPosition: SnackPosition.BOTTOM,
                                    margin: EdgeInsets.all(isDesktop ? 16.0 : 16.w),
                                    borderRadius: isDesktop ? 8.0 : 8.r,
                                  );
                                  return;
                                }
                                if (_selectedCountry.isEmpty) {
                                  Get.snackbar(
                                    "Error",
                                    "Please select a country",
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                  return;
                                }

                                controller.setBasicInfo(
                                  role: widget.isCompany ? 'employer' : 'employee',
                                  firstName: _firstNameController.text.trim(),
                                  lastName: _lastNameController.text.trim(),
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text,
                                  country: _selectedCountry,
                                  sendEmails: _sendEmails,
                                  termsAccepted: _agreed,
                                );

                                if (widget.isCompany) {
                                  Get.offAll(() => EmployerProfileCompleteScreen(
                                      country: _selectedCountry));
                                } else {
                                  Get.offAll(() => EmployeeProfileCompleteScreen(
                                        firstName: _firstNameController.text.trim(),
                                        lastName: _lastNameController.text.trim(),
                                        email: _emailController.text.trim(),
                                        password: _passwordController.text,
                                        country: _selectedCountry,
                                        sendEmails: _sendEmails,
                                        termsAccepted: _agreed,
                                      ));
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(isDesktop ? 8.0 : 8.r),
                          ),
                          elevation: 0,
                        ),
                        child: loading
                            ? SizedBox(
                                height: isDesktop ? 20.0 : 20.h,
                                width: isDesktop ? 20.0 : 20.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                ),
                              )
                            : Text(
                                'Create my account',
                                style: TextStyle(
                                  fontSize: isDesktop ? 14.0 : 15.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    );
                  }),

                  SizedBox(height: isDesktop ? 24.0 : 24.h),

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(
                          fontSize: isDesktop ? 13.0 : 13.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Get.to(() => const LoginScreen()),
                        child: Text(
                          'Log In',
                          style: TextStyle(
                            fontSize: isDesktop ? 13.0 : 13.sp,
                            fontWeight: FontWeight.w600,
                            color: kGreen,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: isDesktop ? 20.0 : 20.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required bool isDesktop,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isDesktop ? 13.0 : 13.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: isDesktop ? 6.0 : 8.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          textAlignVertical: TextAlignVertical.center,
          style: TextStyle(
            fontSize: isDesktop ? 14.0 : 14.sp,
            color: Colors.black87,
          ),
          decoration: _decoration(hint: label),
        ),
        SizedBox(height: isDesktop ? 12.0 : 0),
      ],
    );
  }

  Widget _buildPasswordField({required bool isDesktop}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: TextStyle(
            fontSize: isDesktop ? 13.0 : 13.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: isDesktop ? 6.0 : 8.h),
        TextFormField(
          controller: _passwordController,
          obscureText: !_showPassword,
          textAlignVertical: TextAlignVertical.center,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Password is required';
            if (value.length < 8) return 'Password must be at least 8 characters';
            return null;
          },
          style: TextStyle(
            fontSize: isDesktop ? 14.0 : 14.sp,
            color: Colors.black87,
          ),
          decoration: _decoration(
            hint: "Password (min 8 characters)",
            prefixIcon: Icon(
              Icons.lock_outline,
              size: isDesktop ? 18.0 : 18.sp,
              color: Colors.grey,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _showPassword ? Icons.visibility_off : Icons.visibility,
                size: isDesktop ? 18.0 : 18.sp,
                color: Colors.grey.shade600,
              ),
              onPressed: () => setState(() => _showPassword = !_showPassword),
            ),
          ),
        ),
        SizedBox(height: isDesktop ? 12.0 : 0),
      ],
    );
  }

  // SEARCHABLE COUNTRY DROPDOWN - ALL COUNTRIES WILL SHOW
  Widget _buildSearchableCountryDropdown({required bool isDesktop}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Country',
          style: TextStyle(
            fontSize: isDesktop ? 13.0 : 13.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: isDesktop ? 6.0 : 8.h),
        
        // Selected Country Display
        GestureDetector(
          onTap: () => _showCountrySearchDialog(isDesktop),
          child: Container(
            height: isDesktop ? 44.0 : 48.h,
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 12.0 : 16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(isDesktop ? 8.0 : 8.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                if (_selectedCountry.isNotEmpty)
                  _buildCountryFlag(_selectedCountry, size: 20)
                else
                  Icon(Icons.public, size: 18, color: Colors.grey.shade500),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedCountry.isEmpty ? 'Select country' : _selectedCountry,
                    style: TextStyle(
                      fontSize: isDesktop ? 14.0 : 14.sp,
                      color: _selectedCountry.isEmpty ? Colors.grey.shade500 : Colors.black87,
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.grey.shade500, size: 20),
              ],
            ),
          ),
        ),
        SizedBox(height: isDesktop ? 12.0 : 0),
        
        // Show loading or error message
        if (_isLoadingCountries)
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Text('Loading countries...', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        if (_hasError && !_isLoadingCountries)
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Text(
              'Using offline country list',
              style: TextStyle(fontSize: 12, color: Colors.orange),
            ),
          ),
      ],
    );
  }

  void _showCountrySearchDialog(bool isDesktop) {
    String searchQuery = '';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          // Get filtered countries based on search
          List<CountryModel> filteredCountries = _countries;
          if (searchQuery.isNotEmpty) {
            filteredCountries = _countries
                .where((country) => country.name.toLowerCase().contains(searchQuery.toLowerCase()))
                .toList();
          }
          
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.8, // Increased height
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Country (${filteredCountries.length} countries)',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Search Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: TextField(
                      autofocus: true,
                      onChanged: (value) {
                        setStateDialog(() {
                          searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search country... (${_countries.length} countries available)',
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 20),
                        suffixIcon: searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.close, color: Colors.grey[500], size: 20),
                                onPressed: () {
                                  setStateDialog(() {
                                    searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Countries List - ALL countries will show here
                  Expanded(
                    child: _isLoadingCountries
                        ? const Center(child: CircularProgressIndicator())
                        : filteredCountries.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.public_off, size: 48, color: Colors.grey[400]),
                                    const SizedBox(height: 8),
                                    Text('No countries found', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: filteredCountries.length,
                                itemBuilder: (context, index) {
                                  final country = filteredCountries[index];
                                  final isSelected = _selectedCountry == country.name;
                                  return ListTile(
                                    leading: _buildCountryFlag(country.name, size: 30),
                                    title: Text(
                                      country.name,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                        color: isSelected ? kGreen : Colors.black87,
                                      ),
                                    ),
                                    trailing: isSelected
                                        ? Icon(Icons.check_circle, color: kGreen, size: 20)
                                        : null,
                                    onTap: () {
                                      setState(() {
                                        _selectedCountry = country.name;
                                      });
                                      Navigator.pop(context);
                                    },
                                  );
                                },
                              ),
                  ),
                  const SizedBox(height: 8),
                  // Show count
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Showing ${filteredCountries.length} of ${_countries.length} countries',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCountryFlag(String countryName, {double size = 24}) {
    final country = _countries.firstWhere(
      (c) => c.name == countryName,
      orElse: () => CountryModel(name: '', code: '', flagUrl: ''),
    );
    
    if (country.flagUrl.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            countryName.isNotEmpty ? countryName[0].toUpperCase() : '?',
            style: TextStyle(fontSize: size * 0.5, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
    
    return Image.network(
      country.flagUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            countryName.isNotEmpty ? countryName[0].toUpperCase() : '?',
            style: TextStyle(fontSize: size * 0.5, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

// Country Model
class CountryModel {
  final String name;
  final String code;
  final String flagUrl;
  
  CountryModel({
    required this.name,
    required this.code,
    required this.flagUrl,
  });
}