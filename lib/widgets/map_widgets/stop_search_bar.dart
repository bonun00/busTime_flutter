import 'package:flutter/material.dart';

Widget buildSearchBar(
    BuildContext context,
    TextEditingController controller,
    List<dynamic> searchResults,
    bool isSearching, {
      required Function(String) onSearchChanged,
      required Function(dynamic) onStopSelected,
      required VoidCallback onClear,
    }) {
  return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.white,
          child: TextField(
            controller: controller,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: '정류장 이름으로 검색',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF388E3C)),
              suffixIcon: controller.text.isEmpty
                  ? null
                  : IconButton(
                icon: const Icon(Icons.clear),
                onPressed: onClear,
              ),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        if (isSearching)
          Container(
            height: 200,
            color: Colors.white,
            child: searchResults.isEmpty
                ? const Center(child: Text("검색 결과가 없습니다."))
                : ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final stop = searchResults[index];
                return ListTile(
                  leading: const Icon(Icons.location_on, color: Color(0xFF388E3C)),
                  title: Text(stop['nodeNm'] ?? ''),
                  subtitle: Text("정류장 ID: ${stop['nodeId']}"),
                  onTap: () => onStopSelected(stop),
                );
              },
            ),
          )
      ],
    );

}