# clean_getx CLI

A Dart CLI tool for scaffolding Flutter projects with a feature-first clean
architecture using GetX — grouped by page under `presentation/`.

---

## Requirements

- Dart SDK >= 3.0.0 (comes bundled with Flutter)
- Run all commands from the **root of your Flutter project**

---

## Setup

```bash
cd clean_getx
dart pub get
```

Optionally compile to a standalone binary:

```bash
dart compile exe bin/clean_getx.dart -o clean_getx
```

---

## Commands

### 1. `init` — Scaffold a new Flutter project

Run once inside a freshly created Flutter project to generate the full clean
GetX folder structure and rewrite `pubspec.yaml`.

```bash
dart run /path/to/clean_getx/bin/clean_getx.dart init
```

| Option | Short | Default | Description |
|---|---|---|---|
| `--path` | `-p` | `.` | Root of the target Flutter project |
| `--force` | `-f` | `false` | Overwrite existing `lib/` files without asking |
| `--sqlite` | | `false` | Add SQLite support (`sqflite` + `path`) |
| `--storage` | | `false` | Add local-storage support (`get_storage`) |

**pubspec.yaml rewrite:**

- Preserves all existing `dependencies` and `dev_dependencies` exactly as written
- Always injects: `get`, `intl`
- `--sqlite` injects: `sqflite`, `path`
- `--storage` injects: `get_storage`
- Removes all comments except the standard assets & fonts placeholders

**Generated structure:**

```
lib/
├── main.dart
├── routes/
│   ├── app_pages.dart
│   └── app_routes.dart
├── core/
│   ├── configs/
│   │   ├── text_style/
│   │   │   └── app_text_styles.dart
│   │   └── theme/
│   │       ├── app_color.dart
│   │       ├── app_colors.dart
│   │       └── app_theme.dart
│   ├── constants/
│   │   ├── app_decorations.dart
│   │   ├── gaps.dart
│   │   ├── margin.dart
│   │   └── padding.dart
│   ├── database/                        ← only with --sqlite
│   │   ├── database_service.dart
│   │   └── table_schemas.dart
│   ├── extensions/
│   │   └── string_extensions.dart
│   ├── services/
│   │   └── local_storage_service.dart   ← only with --storage
│   ├── utils/
│   │   ├── app_validators.dart
│   │   └── currency_formatter.dart
│   └── widgets/
└── features/
    └── splash/
        └── presentation/
            └── splash/
                ├── bindings/splash_binding.dart
                ├── controllers/splash_controller.dart
                └── views/splash_view.dart
```

**Examples:**

```bash
# Basic (get + intl only)
dart run bin/clean_getx.dart init

# With SQLite
dart run bin/clean_getx.dart init --sqlite

# With local storage
dart run bin/clean_getx.dart init --storage

# Both
dart run bin/clean_getx.dart init --sqlite --storage

# Specific project path
dart run bin/clean_getx.dart init --path /path/to/my_app

# Force overwrite existing files
dart run bin/clean_getx.dart init --force
```

After init:

```bash
flutter pub get
```

---

### 2. `generate` — Create a new feature

```bash
dart run bin/clean_getx.dart generate -n <feature_name>
```

| Option | Short | Default | Description |
|---|---|---|---|
| `--name` | `-n` | required | Feature name in `snake_case` |
| `--path` | `-p` | `lib/features` | Output directory |
| `--with-model` | | `true` | Generate `data/models/<name>_model.dart` with JSON serialization |
| `--with-repository` | | `true` | Generate abstract repository + Dio implementation |

**Examples:**

```bash
# Full feature (model + repository — default)
dart run bin/clean_getx.dart generate -n user

# Presentation only (no model, no repository)
dart run bin/clean_getx.dart generate -n dashboard --no-with-model --no-with-repository
```

**Generated structure (`generate -n user`):**

```
lib/features/user/
├── data/
│   ├── models/
│   │   ├── user_model.dart
│   │   └── models_export.dart
│   └── repositories/
│       └── user_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── user_entity.dart
│   ├── repositories/
│   │   └── user_repository.dart
│   └── usecases/
└── presentation/
    └── user/
        ├── binding/
        │   └── user_binding.dart
        ├── controller/
        │   └── user_controller.dart
        ├── view/
        │   └── user_view.dart
        ├── widgets/
        └── user_exports.dart
```

---

### 3. `page` — Add a page to an existing feature

```bash
dart run bin/clean_getx.dart page -f <feature_name> -n <page_name>
```

| Option | Short | Default | Description |
|---|---|---|---|
| `--feature` | `-f` | required | Existing feature folder name |
| `--name` | `-n` | required | New page name in `snake_case` |
| `--path` | `-p` | `lib/features` | Path to features directory |

**Example:**

```bash
dart run bin/clean_getx.dart page -f user -n user_profile
dart run bin/clean_getx.dart page -f user -n edit_user
```

**Generated structure (`page -f user -n user_profile`):**

```
lib/features/user/presentation/user_profile/
├── binding/
│   └── user_profile_binding.dart
├── controller/
│   └── user_profile_controller.dart
├── view/
│   └── user_profile_view.dart
├── widgets/
└── user_profile_exports.dart
```

---

## After generating a feature

1. Add a route in `lib/routes/app_routes.dart`:

```dart
static const user = '/user';
```

2. Register the page in `lib/routes/app_pages.dart`:

```dart
GetPage(
  name: AppRoutes.user,
  page: () => const UserView(),
  binding: UserBinding(),
),
```

3. If models were generated, run build_runner:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Project layout (this CLI)

```
clean_getx/
├── pubspec.yaml
├── README.md
├── bin/
│   └── clean_getx.dart
└── lib/
    ├── commands/
    │   ├── init_command.dart
    │   ├── generate_feature_command.dart
    │   └── generate_page_command.dart
    ├── generators/
    │   ├── init_generator.dart
    │   ├── feature_generator.dart
    │   └── page_generator.dart
    ├── templates/
    │   ├── init_templates.dart
    │   ├── templates.dart
    │   └── page_templates.dart
    └── utils/
        └── exceptions.dart
```

---

## Notes

- Feature and page names must be `snake_case` — lowercase letters, digits, and
  underscores, starting with a letter (e.g. `product_list`, `add_product_v2`).
- The CLI will not overwrite an existing feature or page directory. Remove it
  manually first if you need to regenerate.
- `--with-model` and `--with-repository` are both `true` by default. Pass
  `--no-with-model` or `--no-with-repository` to skip either.
