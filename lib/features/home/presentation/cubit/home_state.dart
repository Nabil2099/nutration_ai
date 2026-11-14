import '../../data/models/home_summary.dart';
import '../../../../core/data/models/user_profile.dart';

enum HomeStatus { initial, loading, loaded, disconnected, error }

class HomeState {
  const HomeState(this.status, {this.summary, this.profile, this.message});
  final HomeStatus status;
  final HomeSummary? summary;
  final UserProfile? profile;
  final String? message;
}
