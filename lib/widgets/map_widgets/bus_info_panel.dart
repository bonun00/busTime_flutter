import 'package:flutter/material.dart';

class BusListPanel extends StatefulWidget {
  final List<dynamic> busList;
  final String? selectedId;
  final Function(dynamic) onSelect;
  final double minHeight;
  final double maxHeight;

  const BusListPanel({
    required this.busList,
    required this.selectedId,
    required this.onSelect,
    this.minHeight = 60,
    this.maxHeight = 500,
    Key? key,
  }) : super(key: key);

  @override
  State<BusListPanel> createState() => _BusListPanelState();
}

class _BusListPanelState extends State<BusListPanel>
    with SingleTickerProviderStateMixin {
  late double _panelHeight;
  bool _isExpanded = true;
  bool _isDragging = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _panelHeight = 250;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _controller.forward();
  }

  void _updatePanelHeight(double delta) {
    setState(() {
      _panelHeight =
          (_panelHeight - delta).clamp(widget.minHeight, widget.maxHeight);

      if (_panelHeight <= widget.minHeight + 30) {
        _isExpanded = false;
        _controller.reverse();
      } else {
        _isExpanded = true;
        _controller.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: _isDragging ? 0 : 300),
      curve: Curves.easeInOut,
      left: 0,
      right: 0,
      bottom: _isExpanded ? 0 : -(_panelHeight - widget.minHeight),
      height: _panelHeight,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              spreadRadius: 0,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          children: [
            GestureDetector(
              onVerticalDragUpdate: (details) {
                setState(() {
                  _isDragging = true;
                  _updatePanelHeight(details.delta.dy);
                });
              },
              onVerticalDragEnd: (details) {
                setState(() {
                  _isDragging = false;
                  if (details.velocity.pixelsPerSecond.dy > 200) {
                    _panelHeight = widget.minHeight;
                    _isExpanded = false;
                    _controller.reverse();
                  } else if (details.velocity.pixelsPerSecond.dy < -200) {
                    _panelHeight = widget.maxHeight;
                    _isExpanded = true;
                    _controller.forward();
                  }
                });
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF388E3C), Color(0xFF2E7D32)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    SizedBox(height: 8),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Icon(Icons.directions_bus, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            "실시간 버스 목록",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "${widget.busList.length}대 운행 중",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF388E3C),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: widget.busList.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline, size: 40, color: Colors.grey[400]),
                    SizedBox(height: 10),
                    Text("실시간 버스 정보가 없습니다.",
                        style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              )
                  : ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 8),
                itemCount: widget.busList.length,
                itemBuilder: (context, index) {
                  final bus = widget.busList[index];
                  String vehicleId =
                      bus['vehicleId']?.toString() ?? 'unknown';
                  String busNumber =
                      bus['busNumber']?.toString() ?? '';
                  bool isSelected = vehicleId == widget.selectedId;

                  return Card(
                    margin:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    elevation: isSelected ? 4 : 1,
                    shadowColor: isSelected
                        ? Color(0xFF388E3C).withOpacity(0.3)
                        : Colors.grey.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected
                            ? Color(0xFF388E3C)
                            : Colors.transparent,
                        width: isSelected ? 2 : 0,
                      ),
                    ),
                    child: InkWell(
                      onTap: () => widget.onSelect(bus),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Color(0xFF388E3C)
                                    : Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  busNumber,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Color(0xFF388E3C),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${bus['routenm'] ?? '정보 없음'}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on,
                                          size: 12,
                                          color: Colors.grey[600]),
                                      SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          "차량 번호 $vehicleId",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Color(0xFF388E3C),
                              size: 14,
                            ),
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
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}