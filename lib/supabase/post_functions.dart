import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;


Future<Map<String, dynamic>> createPost({required String musclegroup, required String title, String? description, required String difficulty,}) async {
  final userId = supabase.auth.currentUser!.id;

  final post = await supabase
      .from('posts')
      .insert({
        'user_id': userId,
        'musclegroup': musclegroup,
        'title': title,
        'description': description,
        'difficulty': difficulty,
      })
      .select()
      .single();

  return post;
}

Future<Map<String, dynamic>> updatePost({required int postId, String? musclegroup, String? title, String? description, String? difficulty,}) async {
  final updates = <String, dynamic>{};
  if (musclegroup != null) updates['musclegroup'] = musclegroup;
  if (title != null) updates['title'] = title;
  if (description != null) updates['description'] = description;
  if (difficulty != null) updates['difficulty'] = difficulty;

  final post = await supabase
      .from('posts')
      .update(updates)
      .eq('id', postId)
      .select()
      .single();

  return post;
}

Future<void> deletePost(int postId) async { await supabase.from('posts').delete().eq('id', postId);}
