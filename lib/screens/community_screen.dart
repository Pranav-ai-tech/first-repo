import 'package:flutter/material.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final List<Post> posts = [
    Post(
      name: 'Premachand',
      handle: '@prema_LLM',
      content:
          'Just completed my internship at Infosys! 🎉 Learned a lot about LLM & backend.',
    ),
    Post(
      name: 'Sharan',
      handle: '@Sharan_LB',
      content:
          'Started preparing for SIH 2026 🚀 Any team looking for Flutter dev?',
    ),
  ];

  void _addPost(String text) {
    setState(() {
      posts.insert(
        0,
        Post(
          name: 'Pranav',
          handle: '@pranav_msba',
          content: text,
        ),
      );
    });
  }

  void _showAddPostDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Create Post'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Share something...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                _addPost(controller.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        backgroundColor: const Color(0xFF6A4FB3),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6A4FB3),
        onPressed: _showAddPostDialog,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return PostCard(post: posts[index]);
        },
      ),
    );
  }
}

// ================= POST MODEL =================
class Post {
  final String name;
  final String handle;
  final String content;
  final List<String> comments;

  Post({
    required this.name,
    required this.handle,
    required this.content,
    this.comments = const [],
  });
}

// ================= POST CARD =================
class PostCard extends StatefulWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final List<String> comments = [];

  void _addComment(String text) {
    setState(() {
      comments.add(text);
    });
  }

  void _showCommentDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Comment'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Write a comment...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                _addComment(controller.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('Comment'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(child: Text(widget.post.name[0])),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.post.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold)),
                    Text(widget.post.handle,
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(widget.post.content),

            const SizedBox(height: 12),

            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.comment),
                  onPressed: _showCommentDialog,
                ),
                Text('${comments.length} comments'),
              ],
            ),

            if (comments.isNotEmpty) ...[
              const Divider(),
              ...comments.map(
                (c) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text('• $c'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
