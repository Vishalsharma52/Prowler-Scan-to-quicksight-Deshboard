resource "aws_quicksight_analysis" "example" {
  analysis_id = "Dashbaord_id"
  name        = var.dashboardname

  # resource "aws_quicksight_dashboard" "your_first_qs_dashboard" {
  #   dashboard_id        = "Dashbaord_id"
  #   name                = var.dashboardname
  # version_description = "disc"
  # permissions {
  #   actions   = ["quicksight:RestoreAnalysis", "quicksight:UpdateAnalysisPermissions", "quicksight:DeleteAnalysis", "quicksight:QueryAnalysis", "quicksight:DescribeAnalysisPermissions", "quicksight:DescribeAnalysis", "quicksight:UpdateAnalysis"]
  #   principal = data.aws_quicksight_user.example.arn
  # }
  depends_on = [aws_quicksight_data_set.athena_data_set]
  theme_arn  = "arn:aws:quicksight::aws:theme/MIDNIGHT"

  definition {
    data_set_identifiers_declarations {
      identifier   = "1"
      data_set_arn = aws_quicksight_data_set.athena_data_set.arn
    }
    sheets {
      name         = "Sheet_one"
      sheet_id     = "965138cb-ebe8"
      content_type = "INTERACTIVE"
      layouts {
        configuration {
          grid_layout {
            elements {
              element_id   = "Piechartid"
              element_type = "VISUAL"
              column_index = 0
              column_span  = 11
              row_index    = 0
              row_span     = 7
            }
            elements {
              element_id   = "compliancestatus"
              element_type = "VISUAL"
              column_index = 11
              column_span  = 11
              row_index    = 0
              row_span     = 7
            }
            elements {
              element_id   = "heatmapchart"
              element_type = "VISUAL"
              column_index = 22
              column_span  = 14
              row_index    = 0
              row_span     = 7
            }
            elements {
              element_id   = "barchart"
              element_type = "VISUAL"
              column_index = 0
              column_span  = 11
              row_index    = 7
              row_span     = 9
            }
            elements {
              element_id   = "bar_chart_id"
              element_type = "VISUAL"
              column_index = 11
              column_span  = 11
              row_index    = 7
              row_span     = 9
            }
            elements {
              element_id   = "table_id"
              element_type = "VISUAL"
              column_index = 22
              column_span  = 14
              row_index    = 7
              row_span     = 21
            }
            elements {
              element_id   = "word_cloud_id"
              element_type = "VISUAL"
              column_index = 0
              column_span  = 22
              row_index    = 16
              row_span     = 12
            }
            elements {
              element_id   = "tree_map_id"
              element_type = "VISUAL"
              column_index = 0
              column_span  = 36
              row_index    = 28
              row_span     = 14
            }
            canvas_size_options {
              screen_canvas_size_options {
                resize_option             = "FIXED"
                optimized_view_port_width = "1600px"
              }
            }
          }
        }
      }
      visuals {
        pie_chart_visual {
          visual_id = "Piechartid"
          title {
            visibility = "VISIBLE"
          }
          subtitle {
            visibility = "VISIBLE"
          }
          chart_configuration {
            field_wells {
              pie_chart_aggregated_field_wells {
                category {
                  categorical_dimension_field {
                    field_id = "severity"
                    column {
                      data_set_identifier = "1"
                      column_name         = "severity"
                    }
                  }
                }
              }
            }
          }
        }
      }
      visuals {
        pie_chart_visual {
          visual_id = "compliancestatus"
          title {
            visibility = "VISIBLE"
          }
          subtitle {
            visibility = "VISIBLE"
          }
          chart_configuration {
            field_wells {
              pie_chart_aggregated_field_wells {
                category {
                  categorical_dimension_field {
                    field_id = "compliancestatus"
                    column {
                      data_set_identifier = "1"
                      column_name         = "compliancestatus"
                    }
                  }
                }
              }
            }
          }
        }
      }
      visuals {
        heat_map_visual {
          visual_id = "heatmapchart"
          title {
            visibility = "VISIBLE"
          }
          chart_configuration {
            field_wells {
              heat_map_aggregated_field_wells {
                rows {
                  categorical_dimension_field {
                    field_id = "severity"
                    column {
                      data_set_identifier = "1"
                      column_name         = "severity"
                    }
                  }
                }
                columns {
                  categorical_dimension_field {
                    field_id = "severitycolumn"
                    column {
                      data_set_identifier = "1"
                      column_name         = "resourcetype"
                    }
                  }
                }
              }
            }
          }
        }
      }
      visuals {
        bar_chart_visual {
          visual_id = "barchart"
          title {
            visibility = "VISIBLE"
          }
          subtitle {
            visibility = "VISIBLE"
          }
          chart_configuration {
            field_wells {
              bar_chart_aggregated_field_wells {
                category {
                  categorical_dimension_field {
                    field_id = "severity"
                    column {
                      data_set_identifier = "1"
                      column_name         = "severity"
                    }
                  }
                }
              }
            }
          }
        }
      }
      visuals {
        bar_chart_visual {
          visual_id = "bar_chart_id"
          title {
            visibility = "VISIBLE"
          }
          subtitle {
            visibility = "VISIBLE"
          }
          chart_configuration {
            field_wells {
              bar_chart_aggregated_field_wells {
                category {
                  categorical_dimension_field {
                    field_id = "service"
                    column {
                      data_set_identifier = "1"
                      column_name         = "resourcetype"
                    }
                  }
                }
              }
            }
          }
        }
      }
      visuals {
        word_cloud_visual {
          visual_id = "word_cloud_id"
          title {
            visibility = "VISIBLE"
          }
          subtitle {
            visibility = "VISIBLE"
          }
          chart_configuration {
            field_wells {
              word_cloud_aggregated_field_wells {
                group_by {
                  categorical_dimension_field {
                    field_id = "resourcetypebyservity"
                    column {
                      data_set_identifier = "1"
                      column_name         = "resourcetype"
                    }
                  }
                }
              }
            }
          }
        }
      }
      visuals {
        tree_map_visual {
          visual_id = "tree_map_id"
          title {
            visibility = "VISIBLE"
          }
          subtitle {
            visibility = "VISIBLE"
          }
          chart_configuration {
            field_wells {
              tree_map_aggregated_field_wells {
                groups {
                  categorical_dimension_field {
                    field_id = "resourcetypetree"
                    column {
                      data_set_identifier = "1"
                      column_name         = "resourcetype"
                    }
                  }
                }
                colors {
                  categorical_measure_field {
                    field_id = "severitytypetree"
                    column {
                      data_set_identifier = "1"
                      column_name         = "severity"
                    }
                    aggregation_function = "COUNT"
                  }
                }
              }
            }
            data_labels {
              visibility = "VISIBLE"
              overlap    = "DISABLE_OVERLAP"
            }
            sort_configuration {
              tree_map_group_items_limit_configuration {
                other_categories = "INCLUDE"
              }
            }
          }
        }
      }
      visuals {
        table_visual {
          visual_id = "table_id"
          title {
            visibility = "VISIBLE"
          }
          subtitle {
            visibility = "VISIBLE"
          }
          chart_configuration {
            field_wells {
              table_aggregated_field_wells {
                group_by {
                  categorical_dimension_field {
                    field_id = "severitybyfindings"
                    column {
                      data_set_identifier = "1"
                      column_name         = "severity"
                    }
                  }
                }
                group_by {
                  categorical_dimension_field {
                    field_id = "findingsbyseverity"
                    column {
                      data_set_identifier = "1"
                      column_name         = "findingdescription"
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}