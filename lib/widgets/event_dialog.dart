import 'package:flutter/material.dart';

import 'package:hendrix_today_app/objects/event.dart';
import 'package:hendrix_today_app/widgets/rich_description.dart';

import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:add_2_calendar/add_2_calendar.dart';

/// A detailed display of an [HDXEvent] built on the [AlertDialog] widget.
///
/// This dialog holds all [HDXEvent] information accessible to the user, so its
/// layout must be thoughtfully planned. This widget conforms to the Hendrix
/// College style guide.
///
/// To ensure Users can see titles of extreme length, this widget has been
/// made a Stateful Widget.

class EventDialog extends StatelessWidget {
  const EventDialog({super.key, required this.event});
  final HDXEvent event;

  /// Attempts to begin a draft email to the [HDXEvent.contactEmail].
  ///
  /// Fails if the [event]'s contact email cannot be parsed into a [Uri].
  void _tryEmailContact() async {
    final subject = 'Hendrix Today - response to "${event.title}"';
    final mailto = 'mailto:${event.contactEmail}?subject=$subject';
    final uri = Uri.tryParse(mailto);
    if (uri == null) return;
    // skip the `canLaunchUrl(uri)` check because mailto: links fail
    launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(vertical: 25, horizontal: 50),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(0.0))),
      titlePadding: const EdgeInsets.fromLTRB(0, 24, 18, 0),
      title: Stack(
        children: [
          Container(
            // From https://www.flutterbeads.com/card-border-in-flutter/
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                    color: event.eventType.color(context), width: 16),
              ),
            ),
            padding: const EdgeInsetsDirectional.only(start: 8.0, end: 20.0),
            // minimum height to contain all 3 side buttons
            constraints: const BoxConstraints(minHeight: 160.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EventDialogTitle(eventTitle: event.title),
                Text(
                  event.eventType.toString(),
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: event.eventType.color(context)),
                ),
                const SizedBox(height: 5),
                Text(
                  "∙ ${event.displayDate()}",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (event.time != null)
                  Text(
                    "∙ ${event.time!}",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                if (event.location != null)
                  Text(
                    "∙ ${event.location!}",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
              ],
            ),
          ),
          Positioned(
            top: -15.0,
            right: -15.0,
            child: Column(
              children: [
                IconButton(
                  padding: const EdgeInsets.all(0),
                  color: Theme.of(context).colorScheme.primary,
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: () => Share.share(
                      '"${event.title}" -${event.desc}',
                      subject: 'Check out this event!'),
                  icon: const Icon(Icons.share),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.only(right: 2.0),
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: () => _tryEmailContact(),
                  icon: const Icon(Icons.mail_outlined),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.only(right: 2.0),
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: () {
                    final Event calevent = Event(
                        title: event.time == null
                            ? event.title
                            : "${event.title}: ${event.time}",
                        description: event.desc,
                        location: event.location,
                        startDate: event.date,
                        endDate: event.date,
                        allDay: true);
                    Add2Calendar.addEvent2Cal(calevent);
                  },
                  icon: const Icon(Icons.edit_calendar),
                ),
              ],
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (event.applyDeadline != null) ...[
            Text(
              "This ${event.eventType.toString()} has a deadline: ",
              style: Theme.of(context).textTheme.labelMedium,
            ),
            Text(
              event.displayDeadline()!,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 5),
          ],
          Flexible(
            child: SingleChildScrollView(
              child: RichDescription(text: event.desc),
            ),
          ),
        ],
      ),
    );
  }

  /// This widget creates an elipsis TextButton that only appears
  /// when the maximum title length has been exceeded. This will
  /// allow users to click and view the whole title should they desire.
}

class EventDialogTitle extends StatefulWidget {
  const EventDialogTitle({super.key, required this.eventTitle});
  final String eventTitle;

  @override
  // If there is a better way to do this. Let me know!
  // ignore: no_logic_in_create_state
  State createState() => _EventTitleState(eventTitle: eventTitle);
}

class _EventTitleState extends State<EventDialogTitle> {
  _EventTitleState({required this.eventTitle});
  final String eventTitle;
  int maximumLines = 4;
  bool extended = false;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        eventTitle.toString(),
        style: Theme.of(context).textTheme.headlineLarge,
        maxLines: maximumLines,
      ),
      _buildTextButton()
    ]);
  }

  Widget _buildTextButton() {
    if (eventTitle.length < 80 || extended) {
      return const SizedBox.shrink();
    } else {
      return TextButton(
          onPressed: () {
            setState(() {
              maximumLines = 20;
              extended = true;
            });
          },
          child: const Text(
            "...",
            style: TextStyle(
              // No remaining TextStyles remained, this was the only option.
              color: Color.fromARGB(255, 202, 81, 39),
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          ));
    }
  }
}
