# Codebook for the anonymized release

## General conventions

- Each Excel data sheet has one machine-readable header row.
- Matching CSV files are UTF-8 with a byte-order mark for Excel compatibility.
- Empty cells represent values not reported or not applicable.
- Participant and session identifiers are release-specific and have no published
  crosswalk to source nicknames or source session IDs.
- The two experiments use separate participant-ID namespaces. Identical people
  across experiments cannot be inferred from release IDs.

## `sessions`

| Variable | Type | Description |
|---|---|---|
| `session_id` | text | De-identified release session identifier. |
| `implementation` | categorical | `laboratory` or `online`. |
| `session_sequence` | integer | Chronological sequence within an implementation. |

## `games`

| Variable | Type | Description |
|---|---|---|
| `game_id` | integer | Structural game identifier. Decision records use 1-12 and 14-15. |
| `task_label` | text | Short English task label. |
| `material_file` | text | Matching static HTML material. |
| `special_rule` | categorical | Fixed winning color when applicable. |
| `task_group` | categorical | Basic, One-red-in-N, or Ellsberg grouping. |

`game_id = 13` describes the combined presentation block for games 5-12. It is
not a separate decision record. Questionnaire `answer = 13` refers to that block.

## `participants`

| Variable | Type | Description |
|---|---|---|
| `participant_id` | text | Newly generated experiment-specific identifier. |
| `sex` | categorical | Source value `M` or `F`. |
| `age_group` | categorical | Grouped age; exact source age removed. |
| `student_status` | categorical | Binary `yes`/`no` indicator; source values other than `yes` are coded `no`, following the study's original binary question. |

Five source participants younger than 18 are absent from Experiment I. Only
participants referenced by released response records are included.

## `responses`

| Variable | Type | Unit | Description |
|---|---|---|---|
| `session_id` | text | - | Links to `sessions`. |
| `game_id` | integer | - | Links to `games`. |
| `participant_id` | text | - | Links to `participants`. |
| `presentation_order_code` | integer | - | Original page/block order code; not a uniform 1-14 rank. |
| `selected_color` | categorical | - | Selected or task-fixed color. |
| `stake_amount` | integer | row-specific | Submitted stake. |
| `stake_unit` | categorical | - | `CZK` in Experiment I; `points` in Experiment II. |
| `potential_payoff` | integer | row-specific | Payoff credited after a winning selected draw. |
| `payoff_unit` | categorical | - | `CZK` or `points`. |
| `selected_for_draw` | binary | - | 1 selected; 0 not selected. |
| `response_time_seconds` | integer | seconds | Source Excel duration multiplied by 86,400. |

Experiment I presentation-order codes range from 1 to 17; Experiment II codes
range from 1 to 7 because several structural games were displayed in blocks.

The laboratory potential payoff is 100 CZK in sessions `LAB-S01` through
`LAB-S13` and 300 CZK in `LAB-S14`. The online potential payoff is 100 points.

## `draws`

| Variable | Type | Description |
|---|---|---|
| `session_id` | text | Links to `sessions`. |
| `game_id` | integer | Links to `games`. |
| `source_realization_status` | integer | Preserved source code: 0 pending, 1 not realized, 2 realized. |
| `realization_status_label` | categorical | Human-readable source status. |
| `draw_result` | categorical | Recorded physically drawn color. |
| `total_selected` | integer | Total participants selected for that draw. |
| `selected_randomly` | integer | Randomly selected subset. |
| `quality_flag` | text | Flags a source inconsistency without silently changing it. |

Three Experiment-I rows have source status 1 while also containing a draw result;
they carry `status_not_realized_but_draw_result_present`.

## `questionnaire` (Experiment II only)

| Variable | Type | Unit | Description |
|---|---|---|---|
| `session_id` | text | - | Links to `sessions`. |
| `participant_id` | text | - | Links to `participants`. |
| `question` | integer | - | 1 greatest uncertainty; 2 least uncertainty. |
| `response_time_seconds` | integer | seconds | Converted source duration. |
| `answer` | integer | - | Selected situation or interface-block identifier. |

The release contains 212 rows: 106 complete question pairs from 42 participants.
