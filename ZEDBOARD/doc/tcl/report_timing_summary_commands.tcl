report_timing_summary 
-delay_type min_max -path_type full_clock_expanded -check_timing_verbose -max_paths 10 -nworst 1 -significant_digits 3 -input_pins -nets -name {timing_2}
-delay_type min_max: Selects to report both setup and hold time paths for each clock domain reported.
-path_type full_clock_expanded: Defines the style of the report format.
-check_timing_verbose: Temporarily overrides any message limits and return all messages from this command.
-max_paths 10: The maximum number of paths to report per clock or per path group.
-nworst 1: The number of timing paths to output in the timing report. The timing report will return the <N> worst paths to  endpoints based on the specified value, greater than or equal to 1. The default setting is 1.
-significant_digits 3: The number of significant digits in the output results. The valid range is 0 to 13. The default setting is 3.
-input_pins: Shows input pins in the timing path report.
-nets: (optional) Shows net names in the timing path report.
-name {timing_2}: Specifies a name for the results shown in the GUI.
