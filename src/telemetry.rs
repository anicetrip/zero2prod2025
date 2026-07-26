use tracing::Subscriber;
use tracing::subscriber::set_global_default;
use tracing_bunyan_formatter::{BunyanFormattingLayer, JsonStorageLayer};
use tracing_log::LogTracer;
use tracing_subscriber::fmt::MakeWriter;
use tracing_subscriber::layer::SubscriberExt;
use tracing_subscriber::{EnvFilter, Registry};
pub fn get_subscriber<Sink>(
    name: String,
    env_filter: String,
    sink: Sink,
) -> impl Subscriber + Send + Sync
where
    Sink: for<'a> MakeWriter<'a> + Send + Sync + 'static,
{
    let env_filter =
        EnvFilter::try_from_default_env().unwrap_or_else(|_| EnvFilter::new(env_filter));
    let formatting_layer = BunyanFormattingLayer::new(name, sink);
    Registry::default()
        .with(env_filter)
        .with(JsonStorageLayer)
        .with(formatting_layer)
}

pub fn init_subscriber(subscriber: impl Subscriber + Send + Sync) {
    LogTracer::init().expect("Failed to set logger");
    set_global_default(subscriber).expect("Failed to set subscriber");
}

use actix_web::dev::ServiceRequest;
use tracing::{Span, info_span};
use tracing_actix_web::RootSpanBuilder;
use uuid::Uuid;

pub struct CustomRootSpanBuilder;

impl RootSpanBuilder for CustomRootSpanBuilder {
    fn on_request_start(request: &ServiceRequest) -> Span {
        let request_id = Uuid::new_v4();

        info_span!(
            "http_request",
            request_id = %request_id,
            method = %request.method(),
            path = %request.path(),
            client_ip = ?request.connection_info().realip_remote_addr(),
            user_agent = ?request.headers().get("user-agent"),
        )
    }

    fn on_request_end<B: actix_web::body::MessageBody>(
        _span: Span,
        _outcome: &Result<actix_web::dev::ServiceResponse<B>, actix_web::Error>,
    ) {
        //Do nothing.
    }
}
