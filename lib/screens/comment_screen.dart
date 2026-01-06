import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // For formatting dates

class CommentScreen extends StatefulWidget {
  final int postId;
  final String jwtToken;

  const CommentScreen({required this.postId, required this.jwtToken, super.key});

  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final TextEditingController _commentController = TextEditingController();
  List<Map<String, dynamic>> _comments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://sillysuitcase.com/wp-json/wp/v2/comments?post=${widget.postId}&orderby=date&order=asc'),
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          _comments = data.map((c) => c as Map<String, dynamic>).toList();
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
        debugPrint('Failed to load comments: ${response.body}');
      }
    } catch (e) {
      setState(() => _loading = false);
      debugPrint('Error fetching comments: $e');
    }
  }

  Future<void> _postComment(String content) async {
    if (content.trim().isEmpty) return;

    final url = Uri.parse('https://sillysuitcase.com/wp-json/wp/v2/comments');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.jwtToken}',
        },
        body: jsonEncode({
          'post': widget.postId,
          'content': content,
        }),
      );

      if (response.statusCode == 201) {
        _commentController.clear();
        _fetchComments();
      } else {
        debugPrint('Failed to post comment: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to post comment')),
        );
      }
    } catch (e) {
      debugPrint('Error posting comment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error posting comment')),
      );
    }
  }

  @override
 Widget build(BuildContext context) {
  return Scaffold(
    appBar: PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: AppBar(
        automaticallyImplyLeading: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(25),
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Comments (${_comments.length})',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
    ),
    body: Column(
      children: [
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _comments.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.chat_bubble_outline,
                              size: 80, color: Colors.grey),
                          SizedBox(height: 16),
                          Text("No comments yet.\nBe the first!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _comments.length,
                      itemBuilder: (context, index) {
                        final comment = _comments[index];
                        final date = DateTime.tryParse(comment['date'] ?? '');
                        final formattedDate = date != null
                            ? DateFormat('dd MMM yyyy, hh:mm a').format(date)
                            : '';

                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 4),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.indigo.shade200,
                              child: Text(
                                (comment['author_name'] ?? 'A')
                                    .toString()[0],
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              comment['author_name'] ?? 'Anonymous',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  comment['content']['rendered']
                                      .toString()
                                      .replaceAll(RegExp(r'<[^>]*>'), ''),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  formattedDate,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
        const Divider(height: 1),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: "Add a comment...",
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _postComment(_commentController.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(14),
                ),
                child: const Icon(Icons.send, color: Colors.white),
              )
            ],
          ),
        ),
      ],
    ),
  );
}

}
