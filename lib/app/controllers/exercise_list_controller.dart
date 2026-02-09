import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/app/data/models/exercise_model.dart';
import 'package:flutter_application_2/app/data/repositories/exercise_repository.dart';
import 'package:get/get.dart';

class ExerciseListController extends GetxController {
  // Inisialisasi Repository
  final ExerciseRepository _repository;

  ExerciseListController(this._repository);

  var exercises = <Exercise>[].obs;
  var isLoading = false.obs;
  var isMoreLoading = false.obs;
  var hasMore = true.obs;

  // Variabel untuk menyimpan kursor pagination
  DocumentSnapshot? _lastDocument;

  final ScrollController scrollController = ScrollController();
  Timer? _debounce;
  var currentQuery = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchExercises(); // Panggil fetch awal

    // Listener Infinite Scroll
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        // Cek kondisi sebelum load more
        if (hasMore.value &&
            !isMoreLoading.value &&
            !isLoading.value &&
            currentQuery.isEmpty) {
          loadMore();
        }
      }
    });
  }

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      currentQuery.value = query;
      fetchExercises(query: query);
    });
  }

  // Fungsi Fetch Data Utama (Reset List)
  Future<void> fetchExercises({String query = ""}) async {
    isLoading.value = true;
    _lastDocument = null; // Reset kursor saat refresh/search
    hasMore.value = true;

    try {
      if (query.isNotEmpty) {
        // Mode Search (Langsung ambil semua hasil yang cocok)
        final result = await _repository.searchExercises(query);
        exercises.assignAll(result);
        hasMore.value = false; // Disable load more saat searching
      } else {
        // Mode List Normal (Pakai Pagination)
        final result = await _repository.getExercises(limit: 15);
        exercises.assignAll(result.data);
        _lastDocument = result.lastDocument;

        // Jika data yang didapat kurang dari limit, berarti sudah habis
        if (result.data.length < 15) {
          hasMore.value = false;
        }
      }
    } catch (e) {
      print("Error: $e");
      Get.snackbar("Error", "Gagal memuat data latihan");
    } finally {
      isLoading.value = false;
    }
  }

  // Fungsi Load More (Append Data)
  Future<void> loadMore() async {
    if (isMoreLoading.value || !hasMore.value || _lastDocument == null) return;

    isMoreLoading.value = true;

    try {
      // Panggil repo dengan menyertakan dokumen terakhir
      final result = await _repository.getExercises(
        limit: 15,
        startAfter: _lastDocument,
      );

      if (result.data.isNotEmpty) {
        exercises.addAll(result.data); // Tambahkan ke list bawah
        _lastDocument = result.lastDocument; // Update kursor baru
      } else {
        hasMore.value = false; // Data habis total
      }

      // Double check jika data fetch terakhir lebih sedikit dari limit
      if (result.data.length < 15) {
        hasMore.value = false;
      }
    } catch (e) {
      print("Error loading more: $e");
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
