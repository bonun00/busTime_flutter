import 'package:flutter/material.dart';

class SearchableDropdown extends StatefulWidget {
  final List<String> items;
  final String? value;
  final String hint;
  final Function(String?) onChanged;
  final Color iconColor;

  const SearchableDropdown({
    Key? key,
    required this.items,
    required this.hint,
    required this.onChanged,
    required this.iconColor,
    this.value,
  }) : super(key: key);

  @override
  _SearchableDropdownState createState() => _SearchableDropdownState();
}

class _SearchableDropdownState extends State<SearchableDropdown> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredItems = [];
  bool _isDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  @override
  void didUpdateWidget(SearchableDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _filteredItems = widget.items;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items
            .where((item) => item.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _isDropdownOpen = !_isDropdownOpen;
              if (!_isDropdownOpen) {
                _searchController.clear();
                _filteredItems = widget.items;
              }
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12), // 패딩 증가 (8→12)
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1.5, // 경계선 두께 증가 (1.0→1.5)
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    (widget.value ?? widget.hint).replaceAll(' ', ''),
                    style: TextStyle(
                      color: widget.value == null ? Colors.grey.shade600 : Colors.black,
                      fontSize: 18, // 글자 크기 증가 (16→18)
                    ),
                  ),
                ),
                Icon(
                  _isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: widget.iconColor,
                  size: 28, // 아이콘 크기 증가 (기본→28)
                ),
              ],
            ),
          ),
        ),
        if (_isDropdownOpen) ...[
          SizedBox(height: 12), // 간격 증가 (8→12)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12), // 패딩 증가 (8→12)
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6), // 모서리 둥글기 증가 (4→6)
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '검색...',
                border: InputBorder.none,
                icon: Icon(Icons.search, size: 24), // 아이콘 크기 증가 (20→24)
                contentPadding: EdgeInsets.symmetric(vertical: 12), // 패딩 증가 (8→12)
                hintStyle: TextStyle(fontSize: 18), // 힌트 텍스트 크기 증가
              ),
              style: TextStyle(fontSize: 18), // 입력 텍스트 크기 증가
              onChanged: _filterItems,
            ),
          ),
          SizedBox(height: 12), // 간격 증가 (8→12)
          Container(
            constraints: BoxConstraints(maxHeight: 250), // 최대 높이 증가 (200→250)
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6), // 모서리 둥글기 증가 (4→6)
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                final item = _filteredItems[index];
                final isSelected = item == widget.value;

                return InkWell(
                  onTap: () {
                    widget.onChanged(item);
                    setState(() {
                      _isDropdownOpen = false;
                      _searchController.clear();
                      _filteredItems = widget.items;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 18), // 패딩 증가 (12,16→16,18)
                    color: isSelected ? Colors.grey.shade200 : Colors.transparent,
                    child: Text(
                      item.replaceAll(' ', ''),
                      style: TextStyle(
                        fontSize: 18, // 글자 크기 증가 (기본→18)
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? widget.iconColor : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}