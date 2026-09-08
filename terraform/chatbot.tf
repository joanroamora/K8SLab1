# ==============================================================================
# Vertex AI Agent Builder / Dialogflow CX Chatbot Infrastructure (Layer 1)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. Enable Required Google Cloud AI & Conversational APIs
# ------------------------------------------------------------------------------
resource "google_project_service" "dialogflow" {
  service                    = "dialogflow.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

resource "google_project_service" "discoveryengine" {
  service                    = "discoveryengine.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

resource "google_project_service" "aiplatform" {
  service                    = "aiplatform.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

# ------------------------------------------------------------------------------
# 2. Conversational Agent Resource (Dialogflow CX / Vertex AI Agent Builder Base)
# ------------------------------------------------------------------------------
resource "google_dialogflow_cx_agent" "boutique_agent" {
  display_name             = "boutique-shopping-assistant"
  location                 = "global"
  default_language_code    = "en"
  supported_language_codes = ["es"]
  time_zone                = "America/New_York"
  description              = "Intelligent Conversational Agent for Online Boutique: assists customers with product discovery, pricing inquiries, order tracking, and shipping estimates."
  advanced_settings {
    logging_settings {
      enable_stackdriver_logging = true
    }
  }

  speech_to_text_settings {
    enable_speech_adaptation = true
  }

  depends_on = [
    google_project_service.dialogflow,
    google_project_service.discoveryengine,
    google_project_service.aiplatform
  ]
}

# ------------------------------------------------------------------------------
# 3. Conversational Intents for Online Boutique Inventory & Logistics
# ------------------------------------------------------------------------------
resource "google_dialogflow_cx_intent" "intent_sunglasses" {
  parent       = google_dialogflow_cx_agent.boutique_agent.id
  display_name = "store.products.sunglasses"
  priority     = 500000

  training_phrases {
    repeat_count = 1
    parts {
      text = "quiero unas gafas, vendes algunas?"
    }
  }
  training_phrases {
    repeat_count = 1
    parts {
      text = "I want glasses, do you have?"
    }
  }
  training_phrases {
    repeat_count = 1
    parts {
      text = "sunglasses"
    }
  }
  training_phrases {
    repeat_count = 1
    parts {
      text = "gafas de sol"
    }
  }
}

resource "google_dialogflow_cx_intent" "intent_loafers" {
  parent       = google_dialogflow_cx_agent.boutique_agent.id
  display_name = "store.products.loafers"
  priority     = 500000

  training_phrases {
    repeat_count = 1
    parts {
      text = "necesito unos zapatos"
    }
  }
  training_phrases {
    repeat_count = 1
    parts {
      text = "vendes zapatos?"
    }
  }
  training_phrases {
    repeat_count = 1
    parts {
      text = "Loafers vendes?"
    }
  }
  training_phrases {
    repeat_count = 1
    parts {
      text = "I need shoes"
    }
  }
  training_phrases {
    repeat_count = 1
    parts {
      text = "loafers"
    }
  }
}

resource "google_dialogflow_cx_intent" "intent_watch" {
  parent       = google_dialogflow_cx_agent.boutique_agent.id
  display_name = "store.products.watch"
  priority     = 500000

  training_phrases {
    repeat_count = 1
    parts {
      text = "quiero un reloj"
    }
  }
  training_phrases {
    repeat_count = 1
    parts {
      text = "vendes relojes?"
    }
  }
  training_phrases {
    repeat_count = 1
    parts {
      text = "I want a watch"
    }
  }
}

resource "google_dialogflow_cx_intent" "intent_catalog" {
  parent       = google_dialogflow_cx_agent.boutique_agent.id
  display_name = "store.products.catalog"
  priority     = 500000

  training_phrases {
    repeat_count = 1
    parts {
      text = "qué productos tienen?"
    }
  }
  training_phrases {
    repeat_count = 1
    parts {
      text = "muéstrame el catálogo"
    }
  }
  training_phrases {
    repeat_count = 1
    parts {
      text = "what products do you sell?"
    }
  }
}

resource "google_dialogflow_cx_intent" "intent_shipping" {
  parent       = google_dialogflow_cx_agent.boutique_agent.id
  display_name = "store.shipping.info"
  priority     = 500000

  training_phrases {
    repeat_count = 1
    parts {
      text = "cuánto tarda el envío?"
    }
  }
  training_phrases {
    repeat_count = 1
    parts {
      text = "tiempos de entrega"
    }
  }
  training_phrases {
    repeat_count = 1
    parts {
      text = "how long does delivery take?"
    }
  }
}

resource "google_dialogflow_cx_intent" "intent_pricing" {
  parent       = google_dialogflow_cx_agent.boutique_agent.id
  display_name = "store.pricing.info"
  priority     = 500000

  training_phrases {
    repeat_count = 1
    parts {
      text = "cuáles son los precios?"
    }
  }
  training_phrases {
    repeat_count = 1
    parts {
      text = "precios"
    }
  }
  training_phrases {
    repeat_count = 1
    parts {
      text = "what are your prices?"
    }
  }
}

# ------------------------------------------------------------------------------
# 3. Outputs for Application & Frontend Manifest Integration
# ------------------------------------------------------------------------------
output "chatbot_agent_id" {
  description = "Fully qualified resource name of the Dialogflow CX / Vertex AI Agent"
  value       = google_dialogflow_cx_agent.boutique_agent.id
}

output "chatbot_agent_name" {
  description = "Unique resource identifier path for the Agent"
  value       = google_dialogflow_cx_agent.boutique_agent.name
}

output "chatbot_agent_location" {
  description = "Geographical location where the conversational agent resides"
  value       = google_dialogflow_cx_agent.boutique_agent.location
}

output "chatbot_start_flow" {
  description = "Starting conversational flow ID for the Dialogflow CX agent"
  value       = google_dialogflow_cx_agent.boutique_agent.start_flow
}

output "chatbot_web_snippet" {
  description = "Ready-to-embed HTML/JS Web Component snippet for the Frontend web template"
  value       = <<-EOT
    <!-- Vertex AI Agent Builder / Dialogflow CX Web Messenger -->
    <link rel="stylesheet" href="https://www.gstatic.com/dialogflow-console/fast/df-messenger/prod/v1/themes/df-messenger-default.css">
    <script src="https://www.gstatic.com/dialogflow-console/fast/df-messenger/prod/v1/df-messenger.js"></script>
    <df-messenger
      project-id="${var.project_id}"
      agent-id="${google_dialogflow_cx_agent.boutique_agent.name}"
      language-code="en"
      max-query-length="-1">
      <df-messenger-chat
        chat-title="Online Boutique AI Assistant"
        placeholder-text="Ask about products, prices, shipping...">
      </df-messenger-chat>
    </df-messenger>
  EOT
}
