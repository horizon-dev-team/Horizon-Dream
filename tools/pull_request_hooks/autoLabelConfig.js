// File Labels
//
// Add a label based on if a file is modified in the diff
//
// You can optionally set add_only to make the label one-way -
// if the edit to the file is removed in a later commit,
// the label will not be removed
export const file_labels = {
  '🏭 Github': {
    filepaths: [".github/", '.vscode/'],
  },
  "📚 SQL": {
    filepaths: ["SQL/"],
  },
  '🪓 CORE-CODE': {
    filepaths: ['_maps/map_files/', '_maps/shuttles/', 'code/', 'icons/', 'sound/']
  },
  '🧱 Код': {
    filepaths: ["code/"],
  },
  '🗺 Маппинг': {
    filepaths: ["_maps/"],
    file_extensions: [".dmm"],
  },
  '🚀 Корабли': {
    filepaths: ["_maps/shuttles/", "_maps/configs/", '_maps/_horizon/shuttles/', '_maps/_horizon/configs/'],
    file_extensions: [".dmm"],
  },
  '🏔 Руинки': {
    filepaths: ["_maps/RandomRuins/", "_maps/_horizon/RandomRuins/", "_maps/_horizon/RandomRuins/"],
    file_extensions: [".dmm"],
  },
  '🛠️ Инструменты': {
    filepaths: ["tools/"],
  },
  '🔮 Конфиги': {
    filepaths: ["config/", "code/controllers/configuration/entries/"],
  },
  '🎨 Спрайты': {
    filepaths: ["icons/"],
    file_extensions: [".dmi"],
  },
  '🔊 Звуки': {
    filepaths: ["sound/"],
    file_extensions: ['.aif', '.aiff', '.it', '.mid', '.midi', '.mod', '.mp3', '.ogg', '.oxm', '.raw', '.s3m', '.wma', '.wav', '.xm'],
  },
  "💬 UI": {
    filepaths: ["tgui/"],
  },
  "UpdatePaths 🚧": {
    filepaths: ["tools/UpdatePaths/Scripts/"],
  },
  "CL: ❌": {
    add_only: true,
  },
  "CL: ✔️": {
    add_only: true,
  },
  "CL: 🔘": {
    add_only: true,
  },
};

// Title Labels
//
// Add a label based on keywords in the title
export const title_labels = {
  "📝 Логирование": {
    keywords: ["log", "logging"],
  },
  "🗑️ Удаление": {
    keywords: ["remove", "delete"],
  },
  "🏗 Рефакторинг": {
    keywords: ["refactor"],
  },
  "🧪 Unit Tests": {
    keywords: ["unit test"],
  },
  "🎭 April Fools": {
    keywords: ["[april fools]"],
  },
  "Обновление с TG ☠": {
    keywords: ["[UPDATE-SYNC]"],
  },
  '🛠️ Инструменты': {
    keywords: ["[TGS]"],
  },
};

// Changelog Labels
//
// Adds labels based on keywords in the changelog
// TODO use the existing changelog parser
export const changelog_labels = {
  "🔧 Фикс": {
    default_text: "Исправлена ошибка",
    keywords: ["fix", "fixes", "bugfix", "фикс", "пофиксил", "исправлен", "исправлено", "исправлены"],
  },
  "🔊 Звуки": {
    default_text: "Добавлен/изменен/удален звук",
    keywords: ["sound"],
  },
  "🔩 Улучшение": {
    default_text: "Добавлено что-то новое",
    alt_default_text: "Added more things",
    keywords: ["add", "adds", "rscadd"],
  },
  "🗑️ Удаление": {
    default_text: "Удалено что-то старое",
    keywords: ["del", "dels", "rscdel", "удалено"],
  },
  "🎨 Спрайты": {
    default_text: "Добавлен/изменен/удален спрайт",
    keywords: ["image"],
  },
  "✍️ Текст": {
    default_text: "Исправлена опечатка / Добавлен перевод",
    keywords: ["typo", "spellcheck"],
  },
  "⚖️ Баланс": {
    default_text: "Изменен баланс",
    keywords: ["balance"],
  },
  "🔧 Оптимизация": {
    default_text: "Технические правки кода",
    keywords: ["code_imp", "code"],
  },
  "🏗 Рефакторинг": {
    default_text: "refactored some code",
    keywords: ["refactor"],
  },
  "🔮 Конфиги": {
    default_text: "Изменены настройки конфигурации сервера",
    keywords: ["config"],
  },
  "⚙️ Админские штуки": {
    default_text: "Изменения в кнопках администрации",
    keywords: ["admin"],
  },
};
