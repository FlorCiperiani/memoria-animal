import 'package:get_it/get_it.dart';

import '../data/datasources/card_local_datasource.dart';
import '../data/datasources/game_score_local_datasource.dart';
import '../data/repositories/card_repository_impl.dart';
import '../data/repositories/game_profile_repository_impl.dart';
import '../data/repositories/game_score_repository_impl.dart';
import '../domain/repositories/game_profile_repository.dart';
import '../domain/repositories/game_score_repository.dart';
import '../domain/usecases/check_match.dart';
import '../domain/usecases/generate_board.dart';
import '../presentation/bloc/game_cubit.dart';

final GetIt sl = GetIt.instance;

void configureDependencies() {
  if (sl.isRegistered<GameCubit>()) return;

  sl
    ..registerLazySingleton<CardLocalDataSource>(CardLocalDataSource.new)
    ..registerLazySingleton<GameScoreLocalDataSource>(
      GameScoreLocalDataSource.new,
    )
    ..registerLazySingleton<GameProfileRepository>(
      GameProfileRepositoryImpl.new,
    )
    ..registerLazySingleton<CardRepositoryImpl>(
      () => CardRepositoryImpl(sl<CardLocalDataSource>()),
    )
    ..registerLazySingleton<GameScoreRepository>(
      () => GameScoreRepositoryImpl(sl<GameScoreLocalDataSource>()),
    )
    ..registerLazySingleton<GenerateBoard>(
      () => GenerateBoard(sl<CardRepositoryImpl>()),
    )
    ..registerLazySingleton<CheckMatch>(CheckMatch.new)
    ..registerFactory<GameCubit>(
      () => GameCubit(
        generateBoard: sl<GenerateBoard>(),
        checkMatch: sl<CheckMatch>(),
        scoreRepository: sl<GameScoreRepository>(),
        profileRepository: sl<GameProfileRepository>(),
      ),
    );
}
