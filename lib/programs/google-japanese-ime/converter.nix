{ lib, pkgs }:
{
  # Convert GUI-structured settings to Protobuf flat structure
  # Note: Default values are defined in the option definitions,
  # and Nix's module system will automatically fill them in.
  toProtobufConfig =
    mozcVersion: guiSettings:
    let
      g = guiSettings.general;
      d = guiSettings.dictionary;
      i = guiSettings.input_assistance;
      s = guiSettings.suggestions;
      p = guiSettings.privacy;
      o = guiSettings.other;

      # Get build timestamp (Unix seconds)
      buildTime = builtins.currentTime or 0;

      # Get platform info (mimicking Mozc's SystemUtil::GetOSVersionString())
      platformInfo =
        if pkgs.stdenv.isDarwin then
          "macOS ${pkgs.stdenv.hostPlatform.darwinMinVersion or "unknown"}"
        else
          "NixOS";
    in
    {
      # System metadata (auto-generated, mimicking Mozc's SetMetaData())
      general_config = {
        config_version = 1;
        last_modified_product_version = mozcVersion;
        last_modified_time = buildTime;
        platform = platformInfo;
      };

      # General > Basic
      preedit_method = g.basic.input_mode;
      punctuation_method = g.basic.punctuation;
      symbol_method = g.basic.symbol;
      yen_sign_character = g.basic.yen_sign;
      space_character_form = g.basic.space_input;
      selection_shortcut = g.basic.selection_shortcut;
      numpad_character_form = g.basic.numpad_input;

      # General > Keymap
      session_keymap = g.keymap.preset;
      custom_keymap_table = g.keymap.custom_keymap_table;
      use_keyboard_to_change_preedit_method = g.keymap.use_keyboard_to_change_preedit_method;

      # Dictionary
      history_learning_level = d.learning;
      information_list_config = {
        use_local_usage_dictionary = d.usage_dictionary.use_local_usage_dictionary;
      };

      # Dictionary > Special Conversion
      use_single_kanji_conversion = d.special_conversion.single_kanji;
      use_symbol_conversion = d.special_conversion.symbol;
      use_emoticon_conversion = d.special_conversion.emoticon;
      use_t13n_conversion = d.special_conversion.katakana_english;
      use_zip_code_conversion = d.special_conversion.zip_code;
      use_emoji_conversion = d.special_conversion.emoji;
      use_date_conversion = d.special_conversion.date;
      use_number_conversion = d.special_conversion.number;
      use_calculator = d.special_conversion.calculator;
      use_spelling_correction = d.special_conversion.spelling_correction;

      # Input Assistance
      use_auto_ime_turn_off = i.assistance.auto_switch_to_halfwidth;
      use_auto_conversion = i.assistance.auto_punctuation_conversion;
      auto_conversion_key = i.assistance.auto_conversion_key;
      shift_key_mode_switch = i.assistance.shift_key_mode_switch;
      use_japanese_layout = i.assistance.use_japanese_layout;
      character_form_rules = i.character_width;

      # Suggestions
      use_history_suggest = s.types.from_history;
      use_dictionary_suggest = s.types.from_dictionary;
      use_realtime_conversion = s.types.realtime_conversion;
      suggestions_size = s.other.max_count;

      # Privacy
      incognito_mode = p.incognito_mode;
      presentation_mode = p.presentation_mode;
      upload_usage_stats = p.usage_stats;

      # Other
      check_default = o.check_default;
      use_mode_indicator = o.mode_indicator;
      verbose_level = o.verbose_level;
    };

  # Convert attribute set to textproto format
  toTextProto =
    settings:
    let
      # Fields that contain enum values (not quoted in textproto)
      enumFields = [
        "preedit_method"
        "session_keymap"
        "punctuation_method"
        "symbol_method"
        "yen_sign_character"
        "space_character_form"
        "selection_shortcut"
        "numpad_character_form"
        "history_learning_level"
        "shift_key_mode_switch"
        "preedit_character_form"
        "conversion_character_form"
      ];
      isEnumField = field: builtins.elem field enumFields;

      # Escape special characters in textproto strings
      escapeString =
        str:
        let
          # Escape backslash and double quote
          escaped = builtins.replaceStrings [ ''\'' ''"'' ] [ ''\\'' ''\"'' ] str;
        in
        escaped;

      # Convert a value to textproto string representation
      valueToString =
        key: value:
        if lib.isBool value then
          if value then "true" else "false"
        else if lib.isInt value then
          toString value
        else if lib.isString value then
          if isEnumField key then value else ''"${escapeString value}"''
        else
          throw "Unsupported value type for key ${key}: ${builtins.typeOf value}";

      # Convert a single field to textproto format
      fieldToProto =
        indent: key: value:
        if lib.isBool value || lib.isInt value || lib.isString value then
          "${indent}${key}: ${valueToString key value}"
        else if lib.isAttrs value then
          "${indent}${key} {\n${attrsToProto (indent + "  ") value}\n${indent}}"
        else if lib.isList value then
          lib.concatMapStringsSep "\n" (
            item: "${indent}${key} {\n${attrsToProto (indent + "  ") item}\n${indent}}"
          ) value
        else
          throw "Unsupported field type for ${key}";

      # Convert attribute set to textproto
      attrsToProto =
        indent: attrs: lib.concatStringsSep "\n" (lib.mapAttrsToList (fieldToProto indent) attrs);
    in
    attrsToProto "" settings;
}
