import 'dart:io';

import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/core/database/app_database.dart';
import 'package:budgeting_app/features/access/data/repositories/drift_access_preference_repository.dart';
import 'package:budgeting_app/features/access/domain/entities/access_mode.dart';
import 'package:budgeting_app/features/settings/data/repositories/drift_calendar_preference_repository.dart';
import 'package:budgeting_app/features/settings/data/repositories/drift_theme_preference_repository.dart';
import 'package:budgeting_app/features/settings/domain/entities/app_theme_preference.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase database;
  late DriftAccessPreferenceRepository accessRepository;
  late DriftThemePreferenceRepository themeRepository;
  late DriftCalendarPreferenceRepository calendarRepository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    accessRepository = DriftAccessPreferenceRepository(database);
    themeRepository = DriftThemePreferenceRepository(database);
    calendarRepository = DriftCalendarPreferenceRepository(database);
  });

  tearDown(() => database.close());

  test('access starts undecided, persists guest, and can reset', () async {
    expect(await accessRepository.getAccessMode(), AccessMode.undecided);

    await accessRepository.setGuestMode();
    expect(await accessRepository.getAccessMode(), AccessMode.guest);
    expect(await accessRepository.watchAccessMode().first, AccessMode.guest);

    await accessRepository.resetAccessChoice();
    expect(await accessRepository.getAccessMode(), AccessMode.undecided);
  });

  test('stored authenticated or malformed access never fakes auth', () async {
    await database.writePreference(
      DriftAccessPreferenceRepository.preferenceKey,
      'authenticated',
    );
    expect(await accessRepository.getAccessMode(), AccessMode.undecided);

    await database.writePreference(
      DriftAccessPreferenceRepository.preferenceKey,
      'unexpected',
    );
    expect(await accessRepository.getAccessMode(), AccessMode.undecided);
  });

  test('theme defaults to System and persists Light and Dark', () async {
    expect(await themeRepository.getThemeMode(), AppThemePreference.system);

    await themeRepository.setThemeMode(AppThemePreference.light);
    expect(await themeRepository.getThemeMode(), AppThemePreference.light);

    await themeRepository.setThemeMode(AppThemePreference.dark);
    expect(
      await themeRepository.watchThemeMode().first,
      AppThemePreference.dark,
    );
  });

  test('invalid stored theme value safely restores System', () async {
    await database.writePreference(
      DriftThemePreferenceRepository.preferenceKey,
      'unsupported',
    );

    expect(await themeRepository.getThemeMode(), AppThemePreference.system);
  });

  test('calendar defaults to AD while setup remains incomplete', () async {
    expect(
      await calendarRepository.getPrimaryCalendar(),
      AppCalendarSystem.gregorianAd,
    );
    expect(await calendarRepository.isCalendarSetupComplete(), isFalse);

    await calendarRepository.setPrimaryCalendar(
      AppCalendarSystem.bikramSambatBs,
    );
    expect(
      await calendarRepository.getPrimaryCalendar(),
      AppCalendarSystem.bikramSambatBs,
    );
    expect(await calendarRepository.isCalendarSetupComplete(), isFalse);
  });

  test('calendar setup and selected value persist separately', () async {
    await calendarRepository.markCalendarSetupComplete(
      AppCalendarSystem.bikramSambatBs,
    );

    expect(await calendarRepository.isCalendarSetupComplete(), isTrue);
    expect(
      await calendarRepository.watchPrimaryCalendar().first,
      AppCalendarSystem.bikramSambatBs,
    );

    await calendarRepository.resetCalendarSetup();
    expect(await calendarRepository.isCalendarSetupComplete(), isFalse);
    expect(
      await calendarRepository.getPrimaryCalendar(),
      AppCalendarSystem.bikramSambatBs,
    );
  });

  test('invalid stored calendar value safely falls back to AD', () async {
    await database.writePreference(
      DriftCalendarPreferenceRepository.primaryCalendarKey,
      'unsupported',
    );

    expect(
      await calendarRepository.getPrimaryCalendar(),
      AppCalendarSystem.gregorianAd,
    );
  });

  test('guest and Dark preferences survive database reopening', () async {
    final Directory directory = await Directory.systemTemp.createTemp(
      'budgeting-preferences-reopen-',
    );
    final File databaseFile = File(
      '${directory.path}${Platform.pathSeparator}preferences.sqlite',
    );
    addTearDown(() async {
      if (directory.existsSync()) {
        await directory.delete(recursive: true);
      }
    });

    final AppDatabase databaseA = AppDatabase(NativeDatabase(databaseFile));
    await DriftAccessPreferenceRepository(databaseA).setGuestMode();
    await DriftThemePreferenceRepository(
      databaseA,
    ).setThemeMode(AppThemePreference.dark);
    await DriftCalendarPreferenceRepository(
      databaseA,
    ).markCalendarSetupComplete(AppCalendarSystem.bikramSambatBs);
    await databaseA.close();

    final AppDatabase databaseB = AppDatabase(NativeDatabase(databaseFile));
    expect(
      await DriftAccessPreferenceRepository(databaseB).getAccessMode(),
      AccessMode.guest,
    );
    expect(
      await DriftThemePreferenceRepository(databaseB).getThemeMode(),
      AppThemePreference.dark,
    );
    expect(
      await DriftCalendarPreferenceRepository(databaseB).getPrimaryCalendar(),
      AppCalendarSystem.bikramSambatBs,
    );
    expect(
      await DriftCalendarPreferenceRepository(
        databaseB,
      ).isCalendarSetupComplete(),
      isTrue,
    );
    await databaseB.close();
  });
}
