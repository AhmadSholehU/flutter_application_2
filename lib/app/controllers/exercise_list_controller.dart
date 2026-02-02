import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/app/data/models/exercise_model.dart';
import 'package:flutter_application_2/app/data/services/exercise_api_service.dart';
import 'package:get/get.dart';

class ExerciseListController extends GetxController {
  final ExerciseApiService _apiService = ExerciseApiService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var defaultExercises = <Exercise>[].obs;
  var exercises = <Exercise>[].obs;
  var isLoading = false.obs;
  var isMoreLoading = false.obs;
  var currentOffset = 0;
  var hasMore = true.obs;
  var currentQuery = "".obs;
  String? nextCursor;

  final ScrollController scrollController = ScrollController();
  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();

    // Listener untuk Infinite Scroll
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        if (hasMore.value && !isMoreLoading.value && !isLoading.value) {
          loadMore();
        }
      }
    });
  }

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      currentQuery.value = query;
      fetchInitialData(query: query);
    });
  }

  void fetchInitialData({String query = ""}) async {
    isLoading.value = true;
    currentOffset = 0;
    nextCursor = null;
    currentQuery.value = query;
    hasMore.value = true;

    try {
      if (query.isEmpty) {
        final snapshot = await _firestore.collection('default_exercises').get();
        defaultExercises.assignAll(
          snapshot.docs
              .map((doc) => Exercise.fromJson(doc.data(), docId: doc.id))
              .toList(),
        );
      } else {
        defaultExercises.clear(); // Bersihkan default saat user mulai mencari
      }
      final result = await _apiService.getExercises(after: null, query: query);
      if (result['success'] == true) {
        final List dataList = result['data'] ?? [];
        exercises.assignAll(dataList.map((e) => Exercise.fromJson(e)).toList());

        final meta = result['meta'];
        hasMore.value = meta['hasNextPage'] ?? false;
        nextCursor =
            meta['nextCursor']; // Simpan cursor untuk loadMore berikutnya
      }
    } finally {
      isLoading.value = false;
    }
  }

  void loadMore() async {
    if (isMoreLoading.value || !hasMore.value || nextCursor == null) return;
    isMoreLoading.value = true;

    try {
      final result = await _apiService.getExercises(
        after: nextCursor, // Kirim cursor yang disimpan sebelumnya
        query: currentQuery.value,
      );

      if (result['success'] == true) {
        final List dataList = result['data'] ?? [];
        exercises.addAll(dataList.map((e) => Exercise.fromJson(e)).toList());

        final meta = result['meta'];
        hasMore.value = meta['hasNextPage'] ?? false;
        nextCursor = meta['nextCursor']; // Perbarui cursor terbaru
      }
    } finally {
      isMoreLoading.value = false;
    }
  }

  @override
  void onClose() {
    _debounce?.cancel();
    scrollController.dispose();
    super.onClose();
  }
}
