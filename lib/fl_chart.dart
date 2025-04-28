// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
//
// class CustomBarChart extends StatefulWidget {
//   final List<BarChartGroupData> barGroups;
//   final List<String> bottomTitlesList;
//   final List<Map<String, dynamic>> data;
//   final double maxY;
//   final bool isRounded;
//   final String title;
//   final List<String> rodLabels;
//   final bool isSelected;
//   const CustomBarChart({
//     super.key,
//     required this.barGroups,
//     required this.bottomTitlesList,
//     required this.data,
//     required this.rodLabels,
//     this.maxY = 60,
//     this.title = "",
//     this.isRounded = false,
//     this.isSelected = false,
//   });
//   @override
//   State<CustomBarChart> createState() => _CustomBarChartState();
// }
//
// class _CustomBarChartState extends State<CustomBarChart> {
//   final List<String> rodLabels = ["Working", "Idle", "Breakdown", "Accident"];
//   int? selectedGroupIndex;
//   int? selectedRodIndex;
//   bool isSelectecd = false;
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           SizedBox(
//             height: MediaQuery.sizeOf(context).width,
//             child: Card(
//               color: Colors.white,
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     Text(widget.title, style: MyTextStyle.black.copyWith(fontSize: 14, fontWeight: FontWeight.w500)),
//                     VerticalSpacing.d10px(),
//                     Expanded(
//                       child: SingleChildScrollView(
//                         scrollDirection: Axis.horizontal,
//                         child: SizedBox(
//                           width: widget.barGroups.length * 125,
//                           child: BarChart(
//                             BarChartData(
//                               maxY: widget.maxY,
//                               alignment: BarChartAlignment.spaceAround,
//                               barTouchData: _barTouchData(),
//                               titlesData: _titlesData(widget.bottomTitlesList),
//                               borderData: FlBorderData(show: false),
//                               gridData: FlGridData(
//                                 show: true,
//                                 drawVerticalLine: false,
//                                 horizontalInterval: 10,
//                                 getDrawingHorizontalLine:
//                                     (value) => FlLine(color:  MyColors.gridLineColor, strokeWidth: 1),
//                               ),
//                               barGroups: widget.barGroups,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     VerticalSpacing.d30px(),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children:
//                           widget.data.map((item) {
//                             return Row(
//                               children: [
//                                 Container(
//                                   width: 9,
//                                   height: 9,
//                                   decoration: BoxDecoration(color: item["color"], shape: BoxShape.circle),
//                                 ),
//                                 HorizontalSpacing.custom(value: 6),
//                                 Text(item["label"], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
//                               ],
//                             );
//                           }).toList(),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   BarTouchData _barTouchData() {
//     return BarTouchData(
//       enabled: true,
//       touchTooltipData: BarTouchTooltipData(
//         tooltipPadding: EdgeInsets.zero,
//         tooltipMargin: 10,
//         getTooltipColor: (_) => MyColors.white,
//         tooltipHorizontalAlignment: FLHorizontalAlignment.center,
//         getTooltipItem: (group, groupIndex, rod, rodIndex) {
//           final isSelected = groupIndex == selectedGroupIndex && rodIndex == selectedRodIndex;
//           isSelectecd = isSelected;
//           final label = rodLabels[rodIndex];
//           return BarTooltipItem(
//             isSelected ? '$label\n' : '',
//             MyTextStyle.barHeadLine,
//             children: [
//               TextSpan(
//                 text: isSelected ? '${rod.toY.round()}' : "${rod.toY.round()}",
//                 style: MyTextStyle.barHeadLine.copyWith(color: MyColors.black),
//               ),
//             ],
//           );
//         },
//       ),
//       touchCallback: (event, response) {
//         if (event.isInterestedForInteractions && response != null) {
//           setState(() {
//             selectedGroupIndex = response.spot?.touchedBarGroupIndex;
//             selectedRodIndex = response.spot?.touchedRodDataIndex;
//           });
//         } else {
//           setState(() {
//             selectedGroupIndex = null;
//             selectedRodIndex = null;
//           });
//         }
//       },
//     );
//   }
//
//   FlTitlesData _titlesData(List<String> bottomTitles) {
//     return FlTitlesData(
//       show: true,
//       bottomTitles: AxisTitles(
//         sideTitles: SideTitles(
//           showTitles: true,
//           reservedSize: 30,
//           getTitlesWidget: (value, meta) {
//             final index = value.toInt();
//             return SideTitleWidget(
//               meta: meta,
//               space: 16,
//               child: Text(
//                 index >= 0 && index < bottomTitles.length ? bottomTitles[index] : '',
//                 style: MyTextStyle.bottomStyle,
//               ),
//             );
//           },
//         ),
//       ),
//       leftTitles: AxisTitles(
//         sideTitles: SideTitles(
//           showTitles: true,
//           reservedSize: 30,
//           interval: 10,
//           getTitlesWidget: (value, meta) {
//             if (value % 10 != 0) return const SizedBox.shrink();
//             return SideTitleWidget(
//               meta: meta,
//               space: 10,
//               child: Text(value.toInt().toString(), style: MyTextStyle.leftStyle),
//             );
//           },
//         ),
//       ),
//       topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//       rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//     );
//   }
// }
//
// List<BarChartRodData> buildRodDataList({
//   required List<double> yValues,
//   required List<Color> colors,
//   double width = 12,
//   bool isRounded = false,
//   List<int>? showingTooltipIndicators,
// }) {
//   return List.generate(yValues.length, (index) {
//     return BarChartRodData(
//       toY: yValues[index],
//       color: colors[index],
//       width: width,
//       borderRadius: isRounded ? BorderRadius.circular(6) : BorderRadius.zero,
//     );
//   });
// }
//
// List<BarChartGroupData> generateBarGroups({
//   required bool isRounded,
//   required List<List<double>> groupedYValues,
//   required List<Color> rodColors,
//   double rodWidth = 12,
// }) {
//   return List.generate(groupedYValues.length, (groupIndex) {
//     return BarChartGroupData(
//       x: groupIndex,
//       barsSpace: 4,
//       barRods: buildRodDataList(
//         yValues: groupedYValues[groupIndex],
//         colors: rodColors,
//         width: rodWidth,
//         isRounded: isRounded,
//       ),
//       showingTooltipIndicators: List.generate(groupedYValues[groupIndex].length, (i) => i),
//     );
//   });
// }
//
// class MyColors {
//   static const Color blackColor = Colors.black;
//   static const Color amber = Colors.amber;
//   static const Color containerblackColor = Color(0xff222222);
//   static const Color enableBorderColor = Color(0xffCDD2D9);
//   static const Color textfieldBorder = Color(0xff8A72D8);
//   static const Color ContainerColor = Color(0xff2B8BFC);
//   static const Color lightblue = Color(0xffBAE3F3);
//   static const Color ebcolor = Color(0xff31C6E4);
//   static const Color black = Colors.black;
//   static const Color gradientColor = Color(0xff2DE7D7);
//   static const Color white = Colors.white;
//   static const Color lightgrey = Color(0xffF5F5F5);
//   static const Color purple = Color(0xffCB2D7B);
//   static const Color bgColor = Color(0xff3896FB);
//   static const Color bgColor1 = Color(0xff418EE8);
//   static const Color barColor = Color(0xff6CD6F6);
//   static const Color textfield = Color(0xffF5F6F9);
//   static const Color grey = Color(0xffCADCE3);
//   static const Color pinColor = Color(0xffD2CBEE);
//   static const Color homecontainer = Color(0xffE9F8F7);
//   static const Color darkgrey = Color(0xff707070);
//   static const Color office = Color(0xff9BE4FA);
//   static const Color transport = Color(0xff4F7BB0);
//   static const Color labour = Color(0xff68ADFF);
//   static const Color hintText = Color(0xff081731);
//   static const Color container = Color(0xffE7F2FA);
//   static const Color iconBorderColor = Color(0xffcdcecc);
//   static const Color lightyellow = Color(0xffFFFFED);
//   static const Color gray = Color(0xffA9B2BF);
//   static const Color darkgray = Color(0xff3D3D3D);
//   static const Color price = Color(0xff6E6F70);
//   static const Color greycolor = Color(0xff464545);
//   static const Color labelBorderColor = Color(0xffcdcccb);
//   static const Color lightPink = Color(0xffFDCAE0);
//   static const Color selectedRatingColor = Color(0xffE43A84);
//   static const Color textfieldLabel = Color(0xff646564);
//   static const Color primaryColor = Color(0xff103478);
//   static const Color cardColor = Color(0xffEEEBF8);
//   static const Color green = Colors.green;
//   static const Color darkgreen = Color(0xff013220);
//   static const Color backGroundColor = Color(0xfff9f8f7);
//   static const Color lightPuruple = Color(0xffeeeef8);
//   static const Color darkPuruple = Color(0xffa5a6b3);
//   static const Color fillColor = Color(0xffFBFBFC);
//   static const Color modeColor = Color(0xff0B2046);
//   static const Color backgroundColor = Color(0xffF2F3F5);
//   static Color amberaccent = primaryColor.withOpacity(0.4);
//   static const machineColor = Color(0xff372381);
//   static const chipColors = Color(0xffCDD8EC);
//   static const chipinsideColor = Color(0xffF6F6F6);
//   static const dividerColors = Color(0xffE0E3E9);
//   static const filterColor = Color(0xffC4D5F6);
//   static const filterBgColor = Color(0xffC0C2C7);
//   static const Color calendarColor = Color(0xff858FA2);
//   static const Color logocolor = Color(0xffF3F6F6);
//   static const Color whitegrey = Color(0xffdcdcdc);
//   static const Color successGreen = Color(0xffd57b697);
//   static const Color qrContainerGrey = Color(0xff2D2D2D);
//   static const Color whiteColor = Colors.white;
//   static const Color purpleColor = Color(0xff583C91);
//   static const Color secondaryPrimaryColor = Color(0xff5160b1);
//   static const Color tickSuccess = Color(0xff57B697);
//   static const Color greyTextColor = Color(0xff4B4B4B);
//   static const Color lightPurpleBorder = Color(0xffE4E1F0);
//   static const Color unSuccess = Color(0xffFF5050);
//   static const Color mailcolor = Color(0xff1C1A1A);
//   static const Color dropShadow = Color(0xff00000029);
//   static const Color backgroundcolor = Color(0xffE4EBF7);
//   static const Color title = Color(0xff2C2C2C);
//   static const Color border = Color(0xffDBE8FB);
//   static const Color button = Color(0xff0D4FB5);
//   static const Color locationName = Color(0xff696969);
//   static const Color backGroundWidgetColor = Color(0xffe4eaf7);
//   static const Color textfields = Color(0xff282A3A);
//   static const Color containerBgColor = Color(0xfff5f6fa);
//   static const Color childBG = Color(0xffF4F6FA);
//   static const Color childtitle = Color(0xff0D3F58);
//   static const Color subtitle = Color(0xff46565E);
//   static const Color bgradius = Color(0xffEFF1F6);
//   static const Color carousalcolor = Color(0xff3B94EC);
//   static const Color bgradius1 = Color(0xffE4EAF8);
//   static const Color breakdown = Color(0xffFFDBD9);
//   static const Color breakdownBorder = Color(0xffCC5D5D);
//   static const Color breakdownText = Color(0xffD44B46);
//   static const Color borderColor = Color(0xffD4CFCF);
//   static const Color containerColor = Color(0xffEEEEEE);
//   static const Color workingBorder = Color(0xff55B35F);
//   static const Color workingContainer = Color(0xffBCE9C2);
//   static const Color expensetitle = Color(0xff646464);
//   static const Color greyColor = Color(0xff3D3D3D);
//   static const Color footer = Color(0xff989898);
//   static const Color hintcolor = Color(0xff999999);
//   static const Color iconcolor = Color(0xff7C8AA3);
//   static const Color text = Color(0xff333A48);
//   static const Color reportcolor = Color(0xff686868);
//   static const Color bordercolor = Color(0xffE5E5E5);
//   static const Color workingColor = Color(0xff189159);
//   static const Color idleColor = Color(0xffF87F0E);
//   static const Color breakdownColor = Color(0xffD91E37);
//   static const Color accidentColor = Color(0xff454C58);
//   static const Color expansionColor = Color(0xffE7ECF3);
//   static const Color homeBorder = Color(0xffD4DFEE);
//   static const Color paidColor = Color(0xff32A959);
//   static const Color pendingColor = Color(0xffFF9C49);
//   static const Color vendorColor = Color(0xff535353);
//   static const Color color = Color(0xffF1F1F1);
//   static const Color pluscolor = Color(0xff484848);
//   static const Color uploadcolor = Color(0xffDEE6F1);
//   static const Color settingsColor = Color(0xff434343);
//   static const Color working = Color(0xff6738B8);
//   static const Color idle = Color(0xffFCD270);
//   static const Color breakDownColor = Color(0xffF7921E);
//   static const Color accident = Color(0xff93137A);
//   static const Color barHeadline = Color(0xff0B2046);
//   static const Color leftTitleColor = Color(0xff494949);
//   static const Color bottomTitleColor = Color(0xff0B2046);
//   static const Color gridLineColor = Color(0xffE4E4E4);
// }
//
// class MyTextStyle {
//   static const String robotoFamily = "Roboto";
//   static const header = TextStyle(
//     fontFamily: robotoFamily,
//     fontSize: 18,
//     fontWeight: FontWeight.bold,
//     color: MyColors.black,
//   );
//   static const modeColor = TextStyle(
//     fontSize: 16,
//     fontWeight: FontWeight.w600,
//     color: MyColors.modeColor,
//     fontFamily: robotoFamily,
//   );
//   static const workStyle = TextStyle(
//     fontSize: 24,
//     fontWeight: FontWeight.bold,
//     color: MyColors.workingColor,
//     fontFamily: robotoFamily,
//   );
//   static const bottomStyle = TextStyle(
//     fontSize: 11,
//     fontWeight: FontWeight.bold,
//     color: MyColors.bottomTitleColor,
//     fontFamily: robotoFamily,
//   );
//   static const barHeadLine = TextStyle(
//     fontSize: 11,
//     fontWeight: FontWeight.bold,
//     color: MyColors.barHeadline,
//     fontFamily: robotoFamily,
//   );
//   static const leftStyle = TextStyle(
//     fontSize: 12,
//     fontWeight: FontWeight.bold,
//     color: MyColors.leftTitleColor,
//     fontFamily: robotoFamily,
//   );
//   static const accidentStyle = TextStyle(
//     fontSize: 24,
//     fontWeight: FontWeight.bold,
//     color: MyColors.accidentColor,
//     fontFamily: robotoFamily,
//   );
//   static const chipStyle = TextStyle(color: MyColors.primaryColor, fontWeight: FontWeight.bold, fontSize: 12);
//   static const siteStyle = TextStyle(
//     color: MyColors.primaryColor,
//     fontWeight: FontWeight.w500,
//     fontSize: 12,
//     fontFamily: robotoFamily,
//   );
//   static const breakdown = TextStyle(
//     color: MyColors.breakdownText,
//     fontWeight: FontWeight.w500,
//     fontSize: 21,
//     fontFamily: robotoFamily,
//   );
//   static const machineStyle = TextStyle(
//     fontSize: 24,
//     fontWeight: FontWeight.bold,
//     color: MyColors.machineColor,
//     fontFamily: robotoFamily,
//   );
//   static const idleStyle = TextStyle(
//     fontSize: 24,
//     fontWeight: FontWeight.bold,
//     color: MyColors.idleColor,
//     fontFamily: robotoFamily,
//   );
//   static const breakdownStyle = TextStyle(
//     fontSize: 24,
//     fontWeight: FontWeight.bold,
//     color: MyColors.breakdownColor,
//     fontFamily: robotoFamily,
//   );
//   static const subtext = TextStyle(
//     fontSize: 16,
//     fontWeight: FontWeight.w600,
//     color: MyColors.primaryColor,
//     fontFamily: robotoFamily,
//   );
//   static const hintText = TextStyle(
//     fontSize: 14,
//     fontWeight: FontWeight.w500,
//     color: MyColors.hintText,
//     fontFamily: robotoFamily,
//   );
//   static const buttonStyle = TextStyle(
//     fontSize: 16,
//     fontWeight: FontWeight.bold,
//     color: MyColors.whiteColor,
//     fontFamily: robotoFamily,
//   );
//   static const button = TextStyle(
//     fontFamily: robotoFamily,
//     fontSize: 18,
//     fontWeight: FontWeight.w400,
//     color: MyColors.purple,
//   );
//   static const OtpTitle = TextStyle(
//     fontFamily: robotoFamily,
//     fontSize: 14,
//     fontWeight: FontWeight.w500,
//     color: MyColors.greycolor,
//   );
//   static const subtitle = TextStyle(
//     fontFamily: robotoFamily,
//     fontSize: 11,
//     fontWeight: FontWeight.w300,
//     color: MyColors.subtitle,
//   );
//   static const socialLoginTitle = TextStyle(
//     fontFamily: robotoFamily,
//     fontSize: 14,
//     fontWeight: FontWeight.w500,
//     color: MyColors.greycolor,
//   );
//   static const title = TextStyle(
//     fontFamily: robotoFamily,
//     fontSize: 13,
//     fontWeight: FontWeight.w400,
//     color: MyColors.darkgray,
//   );
//   static const expensetitle = TextStyle(
//     fontFamily: robotoFamily,
//     fontSize: 13,
//     fontWeight: FontWeight.w500,
//     color: MyColors.expensetitle,
//   );
//   static const paidStyle = TextStyle(
//     fontFamily: robotoFamily,
//     fontSize: 13,
//     fontWeight: FontWeight.normal,
//     color: MyColors.paidColor,
//   );
//   static const pendingStyle = TextStyle(
//     fontFamily: robotoFamily,
//     fontSize: 13,
//     fontWeight: FontWeight.w500,
//     color: MyColors.pendingColor,
//   );
//   static const reportLabel = TextStyle(fontFamily: robotoFamily, fontSize: 14, fontWeight: FontWeight.w500);
//   static const mailcolor = TextStyle(
//     fontFamily: robotoFamily,
//     fontSize: 14,
//     fontWeight: FontWeight.w300,
//     color: MyColors.mailcolor,
//   );
//   static const accountProfileName = TextStyle(
//     fontFamily: robotoFamily,
//     fontSize: 16,
//     fontWeight: FontWeight.w500,
//     color: MyColors.darkgray,
//   );
//   static const accountTitle = TextStyle(
//     fontFamily: robotoFamily,
//     fontSize: 12,
//     fontWeight: FontWeight.w500,
//     color: MyColors.darkgray,
//   );
//   static const accountdescription = TextStyle(
//     fontFamily: robotoFamily,
//     fontSize: 14,
//     fontWeight: FontWeight.w700,
//     color: MyColors.black,
//   );
//   static const medium = TextStyle(
//     fontSize: 14,
//     fontWeight: FontWeight.w500,
//     fontFamily: robotoFamily,
//     color: MyColors.blackColor,
//     height: 1.5,
//   );
//   static const medium20px = TextStyle(
//     fontSize: 20,
//     fontWeight: FontWeight.w500,
//     fontFamily: robotoFamily,
//     color: MyColors.blackColor,
//     height: 1.5,
//   );
//   static const reportTextStyle = TextStyle(
//     fontSize: 16,
//     fontWeight: FontWeight.normal,
//     fontFamily: robotoFamily,
//     color: MyColors.greyTextColor,
//     height: 1.5,
//   );
//   static const regular = TextStyle(
//     fontSize: 14,
//     fontWeight: FontWeight.normal,
//     fontFamily: robotoFamily,
//     color: MyColors.blackColor,
//     height: 1.5,
//   );
//   static const medium18 = TextStyle(
//     fontSize: 18,
//     fontWeight: FontWeight.w500,
//     fontFamily: robotoFamily,
//     color: MyColors.blackColor,
//     height: 1.5,
//   );
//   static const buttonMedium = TextStyle(
//     fontSize: 16,
//     fontWeight: FontWeight.w500,
//     fontFamily: robotoFamily,
//     color: MyColors.whiteColor,
//     height: 1.5,
//   );
//   static const label = TextStyle(
//     fontSize: 13,
//     fontWeight: FontWeight.normal,
//     fontFamily: robotoFamily,
//     color: MyColors.white,
//     height: 1.5,
//   );
//   static const textfieldLabel = TextStyle(
//     fontSize: 14,
//     fontWeight: FontWeight.w400,
//     fontFamily: robotoFamily,
//     color: MyColors.blackColor,
//     height: 1.5,
//   );
//   static const price = TextStyle(
//     fontFamily: robotoFamily,
//     fontSize: 13,
//     fontWeight: FontWeight.w300,
//     color: MyColors.price,
//   );
//   static const primaryColor = TextStyle(
//     fontFamily: robotoFamily,
//     fontSize: 15,
//     fontWeight: FontWeight.bold,
//     color: MyColors.primaryColor,
//   );
//   static const productname = TextStyle(
//     fontFamily: robotoFamily,
//     fontSize: 13,
//     fontWeight: FontWeight.w300,
//     color: MyColors.greycolor,
//   );
//   static const darkgreen = TextStyle(
//     fontFamily: robotoFamily,
//     fontSize: 13,
//     fontWeight: FontWeight.w300,
//     color: MyColors.darkgreen,
//   );
//   static const black = TextStyle(
//     fontFamily: robotoFamily,
//     fontSize: 13,
//     fontWeight: FontWeight.w300,
//     color: MyColors.black,
//   );
//   static const camerafont = TextStyle(
//     fontFamily: robotoFamily,
//     fontSize: 14,
//     fontWeight: FontWeight.w300,
//     color: MyColors.whiteColor,
//   );
//   static const locationName = TextStyle(
//     fontFamily: robotoFamily,
//     fontSize: 13,
//     fontWeight: FontWeight.w300,
//     color: MyColors.locationName,
//   );
//   static const dialogConfirmation = TextStyle(
//     fontFamily: robotoFamily,
//     fontSize: 14,
//     fontWeight: FontWeight.w500,
//     color: MyColors.title,
//   );
//   static var dialog = TextStyle(
//     fontFamily: robotoFamily,
//     fontSize: 12,
//     fontWeight: FontWeight.w500,
//     color: MyColors.title.withOpacity(0.5),
//   );
//   static const childtitle = TextStyle(
//     fontFamily: robotoFamily,
//     fontSize: 14,
//     fontWeight: FontWeight.bold,
//     color: MyColors.childtitle,
//   );
//   static const subchildtitle = TextStyle(fontFamily: robotoFamily, fontSize: 12, color: MyColors.subtitle);
//   static const EmpName = TextStyle(
//     fontSize: 13,
//     fontWeight: FontWeight.w500,
//     fontFamily: robotoFamily,
//     color: MyColors.greyColor,
//   );
//   static const register = TextStyle(
//     fontSize: 13,
//     fontWeight: FontWeight.w500,
//     color: MyColors.primaryColor,
//     fontFamily: robotoFamily,
//   );
//   static const hintStyle = TextStyle(
//     fontFamily: robotoFamily,
//     fontSize: 14,
//     fontWeight: FontWeight.w500,
//     color: MyColors.hintcolor,
//   );
//   static const dateStyle = TextStyle(
//     fontFamily: robotoFamily,
//     fontSize: 12,
//     fontWeight: FontWeight.w500,
//     color: MyColors.hintcolor,
//   );
//   static const reportTitle = TextStyle(
//     fontFamily: robotoFamily,
//     fontSize: 15,
//     fontWeight: FontWeight.bold,
//     color: MyColors.childtitle,
//   );
//   static const reportCompanyName = TextStyle(fontFamily: robotoFamily, fontSize: 12, color: MyColors.subtitle);
//   static const reportDate = TextStyle(
//     fontSize: 10,
//     fontFamily: robotoFamily,
//     fontWeight: FontWeight.w500,
//     color: MyColors.hintcolor,
//   );
//   static const text = TextStyle(fontSize: 10, color: MyColors.text, fontFamily: robotoFamily);
//   static const richtext = TextStyle(fontSize: 10, color: MyColors.carousalcolor, fontFamily: robotoFamily);
//   static const landingStyle = TextStyle(fontSize: 32, color: MyColors.white, fontFamily: robotoFamily);
// }
//
// class AppDimens {
//   static const double d2px = 2;
//   static const double d5px = 5;
//   static const double d10px = 10;
//   static const double d15px = 15;
//   static const double d16px = 16;
//   static const double d20px = 20;
//   static const double d30px = 30;
//   static const double d40px = 40;
// }
//
// class HorizontalSpacing extends StatelessWidget {
//   final double spacing;
//   const HorizontalSpacing._(this.spacing);
//   factory HorizontalSpacing.d2px() {
//     return const HorizontalSpacing._(AppDimens.d2px);
//   }
//   factory HorizontalSpacing.d5px() {
//     return const HorizontalSpacing._(AppDimens.d5px);
//   }
//   factory HorizontalSpacing.d10px() {
//     return const HorizontalSpacing._(AppDimens.d10px);
//   }
//   factory HorizontalSpacing.d20px() {
//     return const HorizontalSpacing._(AppDimens.d20px);
//   }
//   factory HorizontalSpacing.d40px() {
//     return const HorizontalSpacing._(AppDimens.d40px);
//   }
//   factory HorizontalSpacing.custom({required double value}) {
//     return HorizontalSpacing._(value);
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Padding(padding: EdgeInsets.only(left: spacing));
//   }
// }
//
// class VerticalSpacing extends StatelessWidget {
//   final double spacing;
//   const VerticalSpacing._(this.spacing);
//   factory VerticalSpacing.d2px() {
//     return const VerticalSpacing._(AppDimens.d2px);
//   }
//   factory VerticalSpacing.d5px() {
//     return const VerticalSpacing._(AppDimens.d5px);
//   }
//   factory VerticalSpacing.d10px() {
//     return const VerticalSpacing._(AppDimens.d10px);
//   }
//   factory VerticalSpacing.d15px() {
//     return const VerticalSpacing._(AppDimens.d15px);
//   }
//   factory VerticalSpacing.d16px() {
//     return const VerticalSpacing._(AppDimens.d16px);
//   }
//   factory VerticalSpacing.d20px() {
//     return const VerticalSpacing._(AppDimens.d20px);
//   }
//   factory VerticalSpacing.d30px() {
//     return const VerticalSpacing._(AppDimens.d30px);
//   }
//   factory VerticalSpacing.d40px() {
//     return const VerticalSpacing._(AppDimens.d40px);
//   }
//   factory VerticalSpacing.custom({required double value}) {
//     return VerticalSpacing._(value);
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Padding(padding: EdgeInsets.only(top: spacing));
//   }
// }
//
// class barChartScreen extends StatefulWidget {
//   const barChartScreen({super.key});
//   @override
//   State<barChartScreen> createState() => _barChartScreenState();
// }
//
// class _barChartScreenState extends State<barChartScreen> {
//   final List<List<double>> groupedYValues = [
//     [30, 10, 20, 5],
//     [30, 10, 20, 5],
//     [30, 10, 20, 5],
//     [30, 10, 20, 5],
//     [30, 10, 20, 5],
//     [30, 10, 20, 5],
//     [30, 10, 20, 5],
//     [30, 10, 20, 5],
//     [30, 10, 20, 5],
//   ];
//   List<Map<String, dynamic>> labelData = [
//     {"label": "Working", "color": MyColors.working},
//     {"label": "Idle", "color": MyColors.idle},
//     {"label": "Breakdown", "color": MyColors.breakDownColor},
//     {"label": "Accident", "color": MyColors.accident},
//   ];
//   final List<Color> rodColors = [MyColors.working, MyColors.idle, MyColors.breakDownColor, MyColors.accident];
//   final List<String> rodLabels = ["Working", "Idle", "Breakdown", "Accident"];
//   List<String> bottomTitles = [
//     "AAMBY PUNE",
//     "CHANDINI CHOWK",
//     "IIT JODHPUR PHASE I",
//     "AAMBY PUNE",
//     "IIT JODHPUR PHASE I",
//     "IIT JODHPUR PHASE I",
//     "CHANDINI CHOWK",
//     "CHANDINI CHOWK",
//     "AAMBY PUNE",
//   ];
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade300,
//       body: CustomBarChart(
//         rodLabels: rodLabels,
//         title: "Asset Status",
//         barGroups: generateBarGroups(
//           rodWidth: 13,
//           groupedYValues: groupedYValues,
//           rodColors: rodColors,
//           isRounded: false,
//         ),
//         maxY: 55,
//         bottomTitlesList: bottomTitles,
//         data: labelData,
//       ),
//     );
//   }
// }
//
// class DotWithLabel extends StatelessWidget {
//   final Color color;
//   final String label;
//   const DotWithLabel({super.key, required this.color, required this.label});
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Container(width: 9, height: 9, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
//         HorizontalSpacing.custom(value: 6),
//         Text(label, style: MyTextStyle.black.copyWith(fontSize: 12)),
//       ],
//     );
//   }
// }
