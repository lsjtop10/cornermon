import 'package:material_ui/material_ui.dart';

import 'package:cornermon/shared/design_system/widgets/responsive_context.dart';

/// 태블릿/PC 폭에서는 목록(2)+상세(3) 좌우 분할, 스마트폰 폭에서는 선택 여부에 따라
/// 목록 또는 상세 하나만 전체 폭으로 보여준다 — 분할 `Row`를 그대로 욱여넣으면 상세
/// 패널이 안 보일 만큼 좁아졌던 문제의 근본 수정이다(#241, "stretch가 아니라
/// restructure"). 공지/다이렉트 메시지 화면이 거의 동일한 분할 레이아웃을 각자
/// 중복 구현하던 것도 이 위젯 하나로 합친다.
///
/// 레이아웃만 책임진다 — 어떤 항목이 선택됐는지(라우트 파라미터 등)는 호출부가 알고
/// [showDetailOnPhone]으로 넘긴다.
class AdaptiveMasterDetail extends StatelessWidget {
  const AdaptiveMasterDetail({
    required this.listPane,
    required this.detailPane,
    required this.showDetailOnPhone,
    super.key,
  });

  final Widget listPane;
  final Widget detailPane;
  final bool showDetailOnPhone;

  @override
  Widget build(BuildContext context) {
    if (context.isPhoneWidth) {
      return showDetailOnPhone ? detailPane : listPane;
    }
    return Row(
      children: [
        Expanded(flex: 2, child: listPane),
        const VerticalDivider(width: 1),
        Expanded(flex: 3, child: detailPane),
      ],
    );
  }
}
