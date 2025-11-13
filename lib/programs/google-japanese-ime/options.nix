{ lib }:
{
  options = {
    programs.google-japanese-ime.settings = lib.mkOption {
      type = lib.types.submodule {
        options = {
          # 一般
          general = lib.mkOption {
            type = lib.types.submodule {
              options = {
                # 基本設定
                basic = lib.mkOption {
                  default = { };
                  type = lib.types.submodule {
                    options = {
                      # config.proto: optional PreeditMethod preedit_method = 4 [default = ROMAN];
                      input_mode = lib.mkOption {
                        type = lib.types.enum [
                          "ROMAN"
                          "KANA"
                        ];
                        default = "ROMAN";
                        description = "ローマ字入力・かな入力";
                      };

                      # config.proto: optional PunctuationMethod punctuation_method = 9 [default = KUTEN_TOUTEN];
                      punctuation = lib.mkOption {
                        type = lib.types.enum [
                          "KUTEN_TOUTEN"
                          "COMMA_PERIOD"
                          "KUTEN_PERIOD"
                          "COMMA_TOUTEN"
                        ];
                        default = "KUTEN_TOUTEN";
                        description = "句読点";
                      };

                      # config.proto: optional SymbolMethod symbol_method = 10 [default = CORNER_BRACKET_MIDDLE_DOT];
                      symbol = lib.mkOption {
                        type = lib.types.enum [
                          "CORNER_BRACKET_MIDDLE_DOT"
                          "SQUARE_BRACKET_SLASH"
                          "CORNER_BRACKET_SLASH"
                          "SQUARE_BRACKET_MIDDLE_DOT"
                        ];
                        default = "CORNER_BRACKET_MIDDLE_DOT";
                        description = "記号";
                      };

                      # config.proto: optional YenSignCharacter yen_sign_character = 28 [default = YEN_SIGN];
                      yen_sign = lib.mkOption {
                        type = lib.types.enum [
                          "YEN_SIGN"
                          "BACKSLASH"
                        ];
                        default = "YEN_SIGN";
                        description = "¥キーで入力する文字";
                      };

                      # config.proto: optional FundamentalCharacterForm space_character_form = 11 [default = FUNDAMENTAL_INPUT_MODE];
                      space_input = lib.mkOption {
                        type = lib.types.enum [
                          "FUNDAMENTAL_INPUT_MODE"
                          "FUNDAMENTAL_FULL_WIDTH"
                          "FUNDAMENTAL_HALF_WIDTH"
                        ];
                        default = "FUNDAMENTAL_INPUT_MODE";
                        description = "スペースの入力";
                      };

                      # config.proto: optional SelectionShortcut selection_shortcut = 13 [default = SHORTCUT_123456789];
                      selection_shortcut = lib.mkOption {
                        type = lib.types.enum [
                          "NO_SHORTCUT"
                          "SHORTCUT_123456789"
                          "SHORTCUT_ASDFGHJKL"
                        ];
                        default = "SHORTCUT_123456789";
                        description = "候補選択ショートカット";
                      };

                      # config.proto: optional NumpadCharacterForm numpad_character_form = 29 [default = NUMPAD_INPUT_MODE];
                      numpad_input = lib.mkOption {
                        type = lib.types.enum [
                          "NUMPAD_INPUT_MODE"
                          "NUMPAD_FULL_WIDTH"
                          "NUMPAD_HALF_WIDTH"
                          "NUMPAD_DIRECT_INPUT"
                        ];
                        default = "NUMPAD_INPUT_MODE";
                        description = "テンキーからの入力";
                      };
                    };
                  };
                  description = "基本設定";
                };

                # キー設定
                keymap = lib.mkOption {
                  default = { };
                  type = lib.types.submodule {
                    options = {
                      # config.proto: optional SessionKeymap session_keymap = 5 [default = NONE];
                      preset = lib.mkOption {
                        type = lib.types.enum [
                          "NONE"
                          "CUSTOM"
                          "ATOK"
                          "MSIME"
                          "KOTOERI"
                          "MOBILE"
                          "CHROMEOS"
                          "HENKAN_SELECT_CANDIDATES"
                        ];
                        default = "NONE";
                        description = "キー設定の選択";
                      };

                      # config.proto: optional bytes custom_keymap_table = 42;
                      # TSV format: "status\tkey\tcommand\n..."
                      custom_keymap_table = lib.mkOption {
                        type = lib.types.str;
                        default = "";
                        description = "カスタムキーマップテーブル（TSV形式）";
                      };

                      # config.proto: optional bool use_keyboard_to_change_preedit_method = 48 [default = false];
                      use_keyboard_to_change_preedit_method = lib.mkOption {
                        type = lib.types.bool;
                        default = false;
                        description = "キーボードで入力モードを変更";
                      };
                    };
                  };
                  description = "キー設定";
                };
              };
            };
            default = { };
            description = "一般";
          };

          # 辞書
          dictionary = lib.mkOption {
            default = { };
            type = lib.types.submodule {
              options = {
                # config.proto: optional HistoryLearningLevel history_learning_level = 12 [default = DEFAULT_HISTORY];
                learning = lib.mkOption {
                  type = lib.types.enum [
                    "DEFAULT_HISTORY"
                    "READ_ONLY"
                    "NO_HISTORY"
                  ];
                  default = "DEFAULT_HISTORY";
                  description = "学習機能";
                };

                # 用例辞書
                usage_dictionary = lib.mkOption {
                  default = { };
                  type = lib.types.submodule {
                    options = {
                      # config.proto: optional InformationListConfig information_list_config = 24;
                      use_local_usage_dictionary = lib.mkOption {
                        type = lib.types.bool;
                        default = true;
                        description = "同音異義語辞書";
                      };
                    };
                  };
                  description = "用例辞書";
                };

                # 特殊変換
                special_conversion = lib.mkOption {
                  default = { };
                  type = lib.types.submodule {
                    options = {
                      # config.proto: optional bool use_single_kanji_conversion = 36 [default = true];
                      single_kanji = lib.mkOption {
                        type = lib.types.bool;
                        default = true;
                        description = "単漢字変換";
                      };

                      # config.proto: optional bool use_symbol_conversion = 37 [default = true];
                      symbol = lib.mkOption {
                        type = lib.types.bool;
                        default = true;
                        description = "記号変換";
                      };

                      # config.proto: optional bool use_emoticon_conversion = 39 [default = true];
                      emoticon = lib.mkOption {
                        type = lib.types.bool;
                        default = true;
                        description = "顔文字変換";
                      };

                      # config.proto: optional bool use_t13n_conversion = 41 [default = true];
                      katakana_english = lib.mkOption {
                        type = lib.types.bool;
                        default = true;
                        description = "カタカナ英語変換";
                      };

                      # config.proto: optional bool use_zip_code_conversion = 42 [default = true];
                      zip_code = lib.mkOption {
                        type = lib.types.bool;
                        default = true;
                        description = "郵便番号変換";
                      };

                      # config.proto: optional bool use_emoji_conversion = 44 [default = true];
                      emoji = lib.mkOption {
                        type = lib.types.bool;
                        default = true;
                        description = "絵文字変換";
                      };

                      # config.proto: optional bool use_date_conversion = 35 [default = true];
                      date = lib.mkOption {
                        type = lib.types.bool;
                        default = true;
                        description = "日付変換";
                      };

                      # config.proto: optional bool use_number_conversion = 38 [default = true];
                      number = lib.mkOption {
                        type = lib.types.bool;
                        default = true;
                        description = "特殊数字変換";
                      };

                      # config.proto: optional bool use_calculator = 40 [default = true];
                      calculator = lib.mkOption {
                        type = lib.types.bool;
                        default = true;
                        description = "計算機機能";
                      };

                      # config.proto: optional bool use_spelling_correction = 43 [default = true];
                      spelling_correction = lib.mkOption {
                        type = lib.types.bool;
                        default = true;
                        description = "「もしかして」変換";
                      };
                    };
                  };
                  description = "特殊変換";
                };
              };
            };
            description = "辞書";
          };

          # 入力補助
          input_assistance = lib.mkOption {
            default = { };
            type = lib.types.submodule {
              options = {
                # 入力補助
                assistance = lib.mkOption {
                  default = { };
                  type = lib.types.submodule {
                    options = {
                      # config.proto: optional bool use_auto_ime_turn_off = 15 [default = true];
                      auto_switch_to_halfwidth = lib.mkOption {
                        type = lib.types.bool;
                        default = true;
                        description = "自動英数変換を有効にする";
                      };

                      # config.proto: optional bool use_auto_conversion = 21 [default = false];
                      auto_punctuation_conversion = lib.mkOption {
                        type = lib.types.bool;
                        default = false;
                        description = "句読点変換を有効にする";
                      };

                      # config.proto: optional ShiftKeyModeSwitch shift_key_mode_switch = 26 [default = OFF];
                      shift_key_mode_switch = lib.mkOption {
                        type = lib.types.enum [
                          "OFF"
                          "ASCII_INPUT_MODE"
                          "KATAKANA_INPUT_MODE"
                        ];
                        default = "OFF";
                        description = "Shiftキーでの入力切り替え";
                      };

                      # config.proto: optional bool use_japanese_layout = 30 [default = false];
                      use_japanese_layout = lib.mkOption {
                        type = lib.types.bool;
                        default = false;
                        description = "日本語入力では常に日本語キー配列を使う";
                      };

                      # config.proto: optional uint32 auto_conversion_key = 62 [default = 13];
                      auto_conversion_key = lib.mkOption {
                        type = lib.types.ints.unsigned;
                        default = 13;
                        description = "自動変換キー";
                      };
                    };
                  };
                  description = "入力補助";
                };

                # 半角・全角
                # config.proto: repeated CharacterFormRule character_form_rules = 14;
                character_width = lib.mkOption {
                  type = lib.types.listOf (
                    lib.types.submodule {
                      options = {
                        group = lib.mkOption {
                          type = lib.types.str;
                          description = "文字グループ";
                        };
                        preedit_character_form = lib.mkOption {
                          type = lib.types.enum [
                            "NO_CONVERSION"
                            "FULL_WIDTH"
                            "HALF_WIDTH"
                            "LAST_FORM"
                          ];
                          description = "変換前文字種";
                        };
                        conversion_character_form = lib.mkOption {
                          type = lib.types.enum [
                            "NO_CONVERSION"
                            "FULL_WIDTH"
                            "HALF_WIDTH"
                            "LAST_FORM"
                          ];
                          description = "変換後文字種";
                        };
                      };
                    }
                  );
                  default = [
                    {
                      group = "ア";
                      preedit_character_form = "FULL_WIDTH";
                      conversion_character_form = "LAST_FORM";
                    }
                    {
                      group = "A";
                      preedit_character_form = "FULL_WIDTH";
                      conversion_character_form = "LAST_FORM";
                    }
                    {
                      group = "0";
                      preedit_character_form = "FULL_WIDTH";
                      conversion_character_form = "LAST_FORM";
                    }
                    {
                      group = "(){}[]";
                      preedit_character_form = "FULL_WIDTH";
                      conversion_character_form = "LAST_FORM";
                    }
                    {
                      group = ".,";
                      preedit_character_form = "FULL_WIDTH";
                      conversion_character_form = "LAST_FORM";
                    }
                    {
                      group = "。、";
                      preedit_character_form = "FULL_WIDTH";
                      conversion_character_form = "FULL_WIDTH";
                    }
                    {
                      group = "・「」";
                      preedit_character_form = "FULL_WIDTH";
                      conversion_character_form = "FULL_WIDTH";
                    }
                    {
                      group = "\"'";
                      preedit_character_form = "FULL_WIDTH";
                      conversion_character_form = "LAST_FORM";
                    }
                    {
                      group = ":;";
                      preedit_character_form = "FULL_WIDTH";
                      conversion_character_form = "LAST_FORM";
                    }
                    {
                      group = "#%&@$^_|`\\";
                      preedit_character_form = "FULL_WIDTH";
                      conversion_character_form = "LAST_FORM";
                    }
                    {
                      group = "~";
                      preedit_character_form = "FULL_WIDTH";
                      conversion_character_form = "LAST_FORM";
                    }
                    {
                      group = "<>=+-/*";
                      preedit_character_form = "FULL_WIDTH";
                      conversion_character_form = "LAST_FORM";
                    }
                    {
                      group = "?!";
                      preedit_character_form = "FULL_WIDTH";
                      conversion_character_form = "LAST_FORM";
                    }
                  ];
                  description = "半角・全角文字変換規則";
                };
              };
            };
            description = "入力補助";
          };

          # サジェスト
          suggestions = lib.mkOption {
            default = { };
            type = lib.types.submodule {
              options = {
                # サジェストの種類
                types = lib.mkOption {
                  default = { };
                  type = lib.types.submodule {
                    options = {
                      # config.proto: optional bool use_history_suggest = 17 [default = true];
                      from_history = lib.mkOption {
                        type = lib.types.bool;
                        default = true;
                        description = "入力履歴からのサジェスト自動表示を有効にする";
                      };

                      # config.proto: optional bool use_dictionary_suggest = 18 [default = true];
                      from_dictionary = lib.mkOption {
                        type = lib.types.bool;
                        default = true;
                        description = "システム辞書からのサジェスト自動表示を有効にする";
                      };

                      # config.proto: optional bool use_realtime_conversion = 19 [default = true];
                      realtime_conversion = lib.mkOption {
                        type = lib.types.bool;
                        default = true;
                        description = "リアルタイム変換を有効にする";
                      };
                    };
                  };
                  description = "サジェストの種類";
                };

                # その他設定
                other = lib.mkOption {
                  default = { };
                  type = lib.types.submodule {
                    options = {
                      # config.proto: optional uint32 suggestions_size = 20 [default = 3];
                      max_count = lib.mkOption {
                        type = lib.types.ints.between 1 9;
                        default = 3;
                        description = "サジェストの最大候補数";
                      };
                    };
                  };
                  description = "その他設定";
                };
              };
            };
            description = "サジェスト";
          };

          # プライバシー
          privacy = lib.mkOption {
            default = { };
            type = lib.types.submodule {
              options = {
                # config.proto: optional bool incognito_mode = 2 [default = false];
                incognito_mode = lib.mkOption {
                  type = lib.types.bool;
                  default = false;
                  description = "シークレットモード";
                };

                # config.proto: optional bool presentation_mode = 27 [default = false];
                presentation_mode = lib.mkOption {
                  type = lib.types.bool;
                  default = false;
                  description = "プレゼンテーションモード";
                };

                # general_config.proto: optional bool upload_usage_stats = 2 [default = false];
                usage_stats = lib.mkOption {
                  type = lib.types.bool;
                  default = false;
                  description = "Googleへのレポート送信";
                };
              };
            };
            description = "プライバシー";
          };

          # その他（システムに依存する設定）
          other = lib.mkOption {
            default = { };
            type = lib.types.submodule {
              options = {
                # config.proto: optional bool check_default = 3 [default = true];
                check_default = lib.mkOption {
                  type = lib.types.bool;
                  default = true;
                  description = "ログイン時に自動起動";
                };

                # config.proto: optional bool use_mode_indicator = 31 [default = true];
                mode_indicator = lib.mkOption {
                  type = lib.types.bool;
                  default = true;
                  description = "モードインジケーター表示";
                };

                # config.proto: optional int32 verbose_level = 1 [default = 0];
                verbose_level = lib.mkOption {
                  type = lib.types.int;
                  default = 0;
                  description = "デバッグログレベル";
                };
              };
            };
            description = "その他";
          };
        };
      };
      description = ''
        Google Japanese IME configuration using GUI-like structure.
        All settings are organized according to the GUI settings panel.
      '';
      example = lib.literalExpression ''
        {
          general.basic = {
            input_mode = "ROMAN";
            punctuation = "KUTEN_TOUTEN";
            symbol = "CORNER_BRACKET_MIDDLE_DOT";
            yen_sign = "BACKSLASH";
          };
          dictionary.special_conversion = {
            emoji = true;
            calculator = true;
          };
          suggestions.types = {
            from_history = true;
            from_dictionary = true;
            realtime_conversion = true;
          };
          privacy = {
            incognito_mode = false;
            usage_stats = false;
          };
        }
      '';
    };
  };
}
