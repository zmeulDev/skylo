import SwiftUI
import WidgetKit

/// Skylo home-screen widget. Renders the snapshot the Flutter app
/// pre-rendered into the shared app-group UserDefaults — display
/// strings only, no business logic (see WidgetSnapshotStore.dart).
///
/// Swiss editorial minimal, same tokens as the app: flat surface,
/// single ink, muted greys, hairline rules, one reserved red accent.
/// The widget follows the system appearance (light/dark variants).

private let appGroupId = "group.com.zmeul.skylo"

// MARK: - Snapshot

struct SkyloSnapshot {
  let placeName: String
  let temp: String
  let tempUnit: String
  let conditionCode: Int
  let hours: [(time: String, temp: String, code: Int?)]
  let days: [(label: String, min: String, max: String, code: Int?)]

  var hasData: Bool { !temp.isEmpty && !placeName.isEmpty }

  static func read() -> SkyloSnapshot? {
    guard let defaults = UserDefaults(suiteName: appGroupId) else { return nil }

    func string(_ key: String) -> String {
      defaults.string(forKey: "skylo.widget.\(key)") ?? ""
    }
    func intOrNull(_ key: String) -> Int? {
      defaults.string(forKey: "skylo.widget.\(key)").flatMap(Int.init)
    }

    var hours: [(String, String, Int?)] = []
    for i in 0..<4 {
      hours.append((string("h\(i)_time"), string("h\(i)_temp"), intOrNull("h\(i)_code")))
    }

    var days: [(String, String, String, Int?)] = []
    for i in 0..<5 {
      days.append((string("d\(i)_label"), string("d\(i)_min"), string("d\(i)_max"), intOrNull("d\(i)_code")))
    }

    return SkyloSnapshot(
      placeName: string("placeName"),
      temp: string("temp"),
      tempUnit: string("tempUnit"),
      conditionCode: intOrNull("weatherCode") ?? -1,
      hours: hours,
      days: days
    )
  }
}

// MARK: - Tokens (spec §2, identical to lib/presentation/theme/app_theme.dart)

struct SkyloPalette {
  let surface: Color
  let ink: Color
  let muted: Color
  let hairline: Color
  let accent: Color
}

func skyloTokens(_ scheme: ColorScheme) -> SkyloPalette {
  scheme == .dark
    ? SkyloPalette(
      surface: Color(.sRGB, red: 0x0D / 255, green: 0x0D / 255, blue: 0x0D / 255),
      ink: Color(.sRGB, red: 0xF2 / 255, green: 0xF2 / 255, blue: 0xF0 / 255),
      muted: Color(.sRGB, red: 0x9A / 255, green: 0x9A / 255, blue: 0x9A / 255),
      hairline: Color(.sRGB, red: 0x26 / 255, green: 0x26 / 255, blue: 0x26 / 255),
      accent: Color(.sRGB, red: 0xFF / 255, green: 0x37 / 255, blue: 0x5F / 255)
    )
    : SkyloPalette(
      surface: Color(.sRGB, red: 0xFA / 255, green: 0xFA / 255, blue: 0xF8 / 255),
      ink: Color(.sRGB, red: 0x0A / 255, green: 0x0A / 255, blue: 0x0A / 255),
      muted: Color(.sRGB, red: 0x8A / 255, green: 0x8A / 255, blue: 0x8A / 255),
      hairline: Color(.sRGB, red: 0xE8 / 255, green: 0xE8 / 255, blue: 0xE8 / 255),
      accent: Color(.sRGB, red: 0xE4 / 255, green: 0x00 / 255, blue: 0x2B / 255)
    )
}

// MARK: - Glyphs (outlined SF symbols; precipitation earns the accent, spec §4.4)

func conditionSymbol(_ code: Int) -> (name: String, accent: Bool) {
  switch code {
  case 200..<300: return ("cloud.bolt.rain", true)
  case 300..<600: return ("cloud.rain", true)
  case 600..<700: return ("cloud.snow", true)
  case 700..<800: return ("cloud.fog", false)
  case 800: return ("sun.max", false)
  case 801...: return ("cloud", false)
  default: return ("circle", false)
  }
}

struct SkyloGlyph: View {
  let code: Int
  let size: CGFloat
  let pal: SkyloPalette

  var body: some View {
    let symbol = conditionSymbol(code)
    Image(systemName: symbol.name)
      .font(Font.system(size: size, weight: .light))
      .foregroundColor(symbol.accent ? pal.accent : pal.ink)
  }
}

// MARK: - Entry & Provider

struct SkyloEntry: TimelineEntry {
  let date: Date
  let snapshot: SkyloSnapshot?
}

struct SkyloProvider: TimelineProvider {
  func placeholder(in context: Context) -> SkyloEntry {
    SkyloEntry(date: Date(), snapshot: SkyloSnapshot.read())
  }

  func getSnapshot(in context: Context, completion: @escaping (SkyloEntry) -> Void) {
    completion(SkyloEntry(date: Date(), snapshot: SkyloSnapshot.read()))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<SkyloEntry>) -> Void) {
    // The app refreshes the snapshot whenever it runs (and on its
    // 15-minute foreground heartbeat); the timeline just re-reads the
    // shared store on the system's cadence.
    let entry = SkyloEntry(date: Date(), snapshot: SkyloSnapshot.read())
    completion(Timeline(entries: [entry], policy: .atEnd))
  }
}

// MARK: - Views

private func wordmark(_ pal: SkyloPalette) -> some View {
  Text("SKYLO")
    .font(Font.system(size: 10, weight: .semibold).monospacedDigit())
    .tracking(3)
    .foregroundColor(pal.ink)
    .frame(maxWidth: .infinity, alignment: .leading)
}

private struct CurrentTemp: View {
  let snapshot: SkyloSnapshot
  let pal: SkyloPalette

  var body: some View {
    HStack(alignment: .bottom, spacing: 2) {
      Text(snapshot.temp)
        .font(Font.system(size: 52, weight: .ultraLight).monospacedDigit())
        .foregroundColor(pal.ink)
        .minimumScaleFactor(0.5)
        .lineLimit(1)
      Text(snapshot.tempUnit)
        .font(Font.system(size: 16, weight: .regular))
        .foregroundColor(pal.accent)
        .padding(.bottom, 6)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

private struct PlaceRow: View {
  let snapshot: SkyloSnapshot
  let pal: SkyloPalette

  var body: some View {
    HStack(spacing: 8) {
      Text(snapshot.placeName)
        .font(Font.system(size: 12, weight: .semibold))
        .foregroundColor(pal.ink)
        .lineLimit(1)
        .truncationMode(.tail)
      Spacer(minLength: 0)
      SkyloGlyph(code: snapshot.conditionCode, size: 14, pal: pal)
    }
  }
}

private struct HourlyRow: View {
  let hours: [(time: String, temp: String, code: Int?)]
  let pal: SkyloPalette

  var body: some View {
    VStack(spacing: 0) {
      Rectangle()
        .fill(pal.hairline)
        .frame(height: 2)
      HStack(alignment: .top, spacing: 0) {
        ForEach(0..<hours.count, id: \.self) { i in
          let hour = hours[i]
          VStack(spacing: 4) {
            Text(hour.time.isEmpty ? "–" : hour.time)
              .font(Font.system(size: 11, weight: .medium).monospacedDigit())
              .foregroundColor(pal.muted)
            SkyloGlyph(code: hour.code ?? -1, size: 13, pal: pal)
            Text(hour.temp.isEmpty ? "" : "\(hour.temp)°")
              .font(Font.system(size: 12, weight: .medium).monospacedDigit())
              .foregroundColor(pal.ink)
          }
          .frame(maxWidth: .infinity)
        }
      }
      .padding(.top, 10)
    }
  }
}

private struct DailyList: View {
  let days: [(label: String, min: String, max: String, code: Int?)]
  let pal: SkyloPalette

  var body: some View {
    VStack(spacing: 0) {
      Rectangle()
        .fill(pal.hairline)
        .frame(height: 2)
      VStack(spacing: 8) {
        ForEach(0..<days.count, id: \.self) { i in
          let day = days[i]
          if !day.label.isEmpty {
            HStack(spacing: 8) {
              Text(day.label)
                .font(Font.system(size: 12, weight: i == 0 ? .semibold : .regular))
                .foregroundColor(pal.ink)
                .lineLimit(1)
              Spacer(minLength: 0)
              SkyloGlyph(code: day.code ?? -1, size: 13, pal: pal)
              Text("\(day.min)°")
                .font(Font.system(size: 12, weight: .medium).monospacedDigit())
                .foregroundColor(pal.muted)
                .frame(width: 34, alignment: .trailing)
              Text("\(day.max)°")
                .font(Font.system(size: 12, weight: .semibold).monospacedDigit())
                .foregroundColor(pal.ink)
                .frame(width: 34, alignment: .trailing)
            }
          }
        }
      }
      .padding(.top, 10)
    }
  }
}

private struct WidgetEmptyContent: View {
  let pal: SkyloPalette

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      wordmark(pal)
      Spacer()
      Text("No weather yet")
        .font(Font.system(size: 16, weight: .semibold))
        .foregroundColor(pal.ink)
      Text("Open Skylo once to fill this widget.")
        .font(Font.system(size: 12, weight: .regular))
        .foregroundColor(pal.muted)
      Spacer()
    }
  }
}

// MARK: - Widget

struct SkyloWidgetEntryView: View {
  @Environment(\.widgetFamily) private var family
  @Environment(\.colorScheme) private var scheme
  var entry: SkyloEntry

  var body: some View {
    let pal = skyloTokens(scheme)
    Group {
      if let snapshot = entry.snapshot, snapshot.hasData {
        switch family {
        case .systemSmall:
          VStack(alignment: .leading, spacing: 8) {
            wordmark(pal)
            Spacer(minLength: 0)
            CurrentTemp(snapshot: snapshot, pal: pal)
            PlaceRow(snapshot: snapshot, pal: pal)
            Spacer(minLength: 0)
          }
        case .systemMedium:
          VStack(alignment: .leading, spacing: 8) {
            wordmark(pal)
            CurrentTemp(snapshot: snapshot, pal: pal)
            PlaceRow(snapshot: snapshot, pal: pal)
            Spacer(minLength: 0)
            HourlyRow(hours: snapshot.hours, pal: pal)
          }
        default:
          VStack(alignment: .leading, spacing: 8) {
            wordmark(pal)
            CurrentTemp(snapshot: snapshot, pal: pal)
            PlaceRow(snapshot: snapshot, pal: pal)
            Spacer(minLength: 0)
            HourlyRow(hours: snapshot.hours, pal: pal)
            DailyList(days: snapshot.days, pal: pal)
          }
        }
      } else {
        WidgetEmptyContent(pal: pal)
      }
    }
    .padding(12)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(pal.surface)
    .widgetURL(URL(string: "skylo://widget?homeWidget"))
  }
}

@main
struct SkyloWidget: Widget {
  let kind: String = "SkyloWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: SkyloProvider()) { entry in
      SkyloWidgetEntryView(entry: entry)
    }
    .configurationDisplayName("Skylo")
    .description("Weather for your last-viewed place.")
    .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
  }
}

struct SkyloWidget_Previews: PreviewProvider {
  static var previews: some View {
    SkyloWidgetEntryView(
      entry: SkyloEntry(date: Date(), snapshot: SkyloSnapshot.read())
    )
    .previewContext(WidgetPreviewContext(family: .systemMedium))
  }
}