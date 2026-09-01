package com.zmeul.skylo

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Skylo home-screen widget. Renders the snapshot the Dart side
 * pre-rendered into the plugin's SharedPreferences — no network, no
 * business logic; display strings only (see WidgetSnapshotStore).
 *
 * One resizable provider with three layout tiers picked by the
 * widget's current width: small (temp), medium (+ hourly row),
 * large (+ 5-day outlook).
 */
class SkyloWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val hasData = widgetData.getString("skylo.widget.temp", null) != null &&
            widgetData.getString("skylo.widget.placeName", null) != null

        appWidgetIds.forEach { id ->
            val views =
                if (hasData) {
                    bindSnapshot(context, id, widgetData, appWidgetManager)
                } else {
                    RemoteViews(context.packageName, R.layout.widget_empty)
                }
            // Anywhere on the widget opens the app.
            views.setOnClickPendingIntent(
                R.id.widget_root,
                HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java),
            )
            appWidgetManager.updateAppWidget(id, views)
        }
    }

    /** Widget resize events rebind with the new size's layout. */
    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: android.os.Bundle?,
    ) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        onUpdate(
            context,
            appWidgetManager,
            intArrayOf(appWidgetId),
            HomeWidgetPlugin.getData(context),
        )
    }

    private fun bindSnapshot(
        context: Context,
        widgetId: Int,
        data: SharedPreferences,
        appWidgetManager: AppWidgetManager,
    ): RemoteViews {
        val options = appWidgetManager.getAppWidgetOptions(widgetId)
        // Portrait and landscape give different width ranges; rebinding
        // picks the layout for whichever orientation is showing.
        val widthDp = maxOf(
            options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH),
            options.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_WIDTH),
        )

        val layout = when {
            widthDp >= 240 -> R.layout.widget_large
            widthDp >= 160 -> R.layout.widget_medium
            else -> R.layout.widget_small
        }
        val views = RemoteViews(context.packageName, layout)

        views.setTextViewText(R.id.temp, data.getString("skylo.widget.temp", null) ?: "--")
        views.setTextViewText(R.id.temp_unit, data.getString("skylo.widget.tempUnit", null) ?: "")
        views.setTextViewText(R.id.place, data.getString("skylo.widget.placeName", null) ?: "")
        setGlyph(views, R.id.condition_glyph, data.getString("skylo.widget.weatherCode", null)?.toIntOrNull())

        if (layout != R.layout.widget_small) {
            for (i in 0 until 4) bindHour(context, views, i, data)
        }
        if (layout == R.layout.widget_large) {
            for (i in 0 until 5) bindDay(context, views, i, data)
        }
        return views
    }

    private fun bindHour(context: Context, views: RemoteViews, i: Int, data: SharedPreferences) {
        val time = data.getString("skylo.widget.h${i}_time", null)
        val temp = data.getString("skylo.widget.h${i}_temp", null)
        val code = data.getString("skylo.widget.h${i}_code", null)?.toIntOrNull()
        views.setTextViewText(id(context, "h${i}_time"), time ?: "")
        views.setTextViewText(id(context, "h${i}_temp"), if (temp == null) "" else "$temp°")
        setGlyph(views, id(context, "h${i}_glyph"), code)
    }

    private fun bindDay(context: Context, views: RemoteViews, i: Int, data: SharedPreferences) {
        val label = data.getString("skylo.widget.d${i}_label", null)
        val min = data.getString("skylo.widget.d${i}_min", null)
        val max = data.getString("skylo.widget.d${i}_max", null)
        val code = data.getString("skylo.widget.d${i}_code", null)?.toIntOrNull()
        views.setTextViewText(id(context, "d${i}_label"), label ?: "")
        views.setTextViewText(id(context, "d${i}_min"), if (min == null) "" else "$min°")
        views.setTextViewText(id(context, "d${i}_max"), if (max == null) "" else "$max°")
        setGlyph(views, id(context, "d${i}_glyph"), code)
    }

    /** OWM code → outlined glyph. Precipitation codes tint accent
     *  via the night/qualified drawables (spec §4.4). */
    private fun setGlyph(views: RemoteViews, viewId: Int, code: Int?) {
        val drawable = when {
            code == null -> R.drawable.widget_glyph_unknown
            code in 200..299 -> R.drawable.widget_glyph_storm
            code in 300..599 -> R.drawable.widget_glyph_rain
            code in 600..699 -> R.drawable.widget_glyph_snow
            code in 700..799 -> R.drawable.widget_glyph_fog
            code == 800 -> R.drawable.widget_glyph_sun
            code > 800 -> R.drawable.widget_glyph_cloud
            else -> R.drawable.widget_glyph_unknown
        }
        views.setImageViewResource(viewId, drawable)
    }

    private fun id(context: Context, name: String): Int =
        context.resources.getIdentifier(name, "id", context.packageName)
}