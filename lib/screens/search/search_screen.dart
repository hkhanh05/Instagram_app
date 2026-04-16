import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // 1. Chỉnh sửa AppBar để chứa thanh tìm kiếm
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[200], // Màu nền xám nhạt
            borderRadius: BorderRadius.circular(10),
          ),
          child: const TextField(
            decoration: InputDecoration(
              hintText: 'Tìm kiếm',
              hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              border: InputBorder.none, // Xóa đường gạch chân mặc định
              contentPadding: EdgeInsets.symmetric(vertical: 10), // Căn giữa chữ
            ),
          ),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(2),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: 30,
        itemBuilder: (_, index) {
          return Image.network(
            'https://picsum.photos/200?random=$index',
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }
}