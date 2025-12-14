import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../features/transactions/data/models/transaccion_recurrente_model.dart';

class NotificationService {
  NotificationService._internal();

  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const AndroidNotificationChannel _recurringChannel =
      AndroidNotificationChannel(
        'transacciones_recurrentes',
        'Transacciones recurrentes',
        description:
            'Recordatorios automáticos para ingresos y gastos programados.',
        importance: Importance.max,
      );

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/launcher_icon',
    );
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(initializationSettings);
    await _configureLocalTimeZone();
    await _createAndroidChannel();
    await _requestPermissions();

    _initialized = true;
  }

  Future<void> scheduleRecurringTransactionNotification(
    TransaccionRecurrente transaccion, {
    bool cancelBeforeScheduling = true,
  }) async {
    await initialize();

    if (cancelBeforeScheduling) {
      await cancelRecurringTransactionNotification(transaccion.id);
    }

    final nextTrigger = _nextTriggerFor(transaccion);
    if (nextTrigger == null) return;

    final matchComponents = _matchComponentsForFrequency(
      transaccion.frecuencia,
    );
    final notificationDetails = _buildNotificationDetails();

    await _plugin.zonedSchedule(
      _notificationIdFor(transaccion.id),
      _buildTitle(transaccion),
      'Abre Kipu para registrar la transacción.',
      nextTrigger,
      notificationDetails,
      payload: transaccion.id,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: matchComponents,
    );
  }

  Future<void> rebuildRecurringTransactionNotifications(
    List<TransaccionRecurrente> transacciones,
  ) async {
    await initialize();
    await _plugin.cancelAll();

    for (final transaccion in transacciones) {
      if (transaccion.activa) {
        await scheduleRecurringTransactionNotification(
          transaccion,
          cancelBeforeScheduling: false,
        );
      }
    }
  }

  Future<void> cancelRecurringTransactionNotification(
    String transaccionId,
  ) async {
    await initialize();
    await _plugin.cancel(_notificationIdFor(transaccionId));
  }

  Future<void> _requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    await _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> _createAndroidChannel() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_recurringChannel);
  }

  NotificationDetails _buildNotificationDetails() {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _recurringChannel.id,
        _recurringChannel.name,
        channelDescription: _recurringChannel.description,
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  DateTimeComponents? _matchComponentsForFrequency(String frecuencia) {
    switch (frecuencia) {
      case 'semanal':
        return DateTimeComponents.dayOfWeekAndTime;
      case 'mensual':
        return DateTimeComponents.dayOfMonthAndTime;
      case 'anual':
        return DateTimeComponents.dateAndTime;
      default:
        return null;
    }
  }

  String _buildTitle(TransaccionRecurrente transaccion) {
    if (transaccion.tipo == 'ingreso') {
      return '¿Ya te pagaron el ${transaccion.descripcion}?';
    }
    return '¿Ya pagaste el ${transaccion.descripcion}?';
  }

  tz.TZDateTime? _nextTriggerFor(TransaccionRecurrente transaccion) {
    final ahora = tz.TZDateTime.now(tz.local);
    tz.TZDateTime candidato = tz.TZDateTime.from(
      transaccion.fechaInicio,
      tz.local,
    );

    // Si hay una fecha de fin específica, evita programar después de esa fecha.
    final DateTime? fechaFin =
        transaccion.condicionFin == 'fecha_especifica' &&
            transaccion.valorFin is DateTime
        ? transaccion.valorFin as DateTime
        : null;

    const int maxIteraciones = 1000;
    int iteraciones = 0;

    while (!candidato.isAfter(ahora) && iteraciones < maxIteraciones) {
      candidato = _sumarPeriodo(candidato, transaccion.frecuencia);
      iteraciones++;
    }

    if (!candidato.isAfter(ahora)) {
      if (kDebugMode) {
        debugPrint(
          'No se pudo calcular una fecha futura para la transacción ${transaccion.id}',
        );
      }
      return null;
    }

    if (fechaFin != null &&
        candidato.isAfter(tz.TZDateTime.from(fechaFin, tz.local))) {
      return null;
    }

    return candidato;
  }

  tz.TZDateTime _sumarPeriodo(tz.TZDateTime fecha, String frecuencia) {
    switch (frecuencia) {
      case 'semanal':
        return fecha.add(const Duration(days: 7));
      case 'mensual':
        final mes = fecha.month + 1;
        final anio = fecha.year + ((mes - 1) ~/ 12);
        final mesNormalizado = ((mes - 1) % 12) + 1;
        final ultimoDiaMes = DateTime(anio, mesNormalizado + 1, 0).day;
        final dia = fecha.day > ultimoDiaMes ? ultimoDiaMes : fecha.day;
        return tz.TZDateTime(
          tz.local,
          anio,
          mesNormalizado,
          dia,
          fecha.hour,
          fecha.minute,
          fecha.second,
        );
      case 'anual':
        return tz.TZDateTime(
          tz.local,
          fecha.year + 1,
          fecha.month,
          fecha.day,
          fecha.hour,
          fecha.minute,
          fecha.second,
        );
      default:
        return fecha.add(const Duration(days: 1));
    }
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    try {
      final timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (_) {
      // Fallback al timezone local por defecto si falla la detección.
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
  }

  int _notificationIdFor(String transactionId) =>
      transactionId.hashCode & 0x7fffffff;
}
