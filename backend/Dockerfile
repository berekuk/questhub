FROM ubuntu:14.04

ENV APP_HOME /play/backend
WORKDIR $APP_HOME

# libssl-dev is needed by Email::Sender::Simple to send Amazon SES emails
# ruby is needed for erb config generation
RUN apt-get update && apt-get install -y libssl-dev sendmail curl supervisor make perl libgd2-xpm-dev ruby

RUN curl -L https://cpanmin.us | perl - --sudo App::cpanminus

RUN cpanm --notest -i Flux::File Flux::Format::JSON Log::Any::Adapter MooX::Options Package::Variant Authen::SASL \
    Net::SMTP::SSL Email::Sender::Transport::SMTP::TLS Email::MIME Net::HTTP YAML Module::Install MongoDB \
    JSON Moo Class::XSAccessor Text::Markdown Clone Email::Sender Log::Any Try::Tiny LWP::Protocol::https \
    DateTime DateTime::Format::RFC3339 Image::Resize Type::Tiny Digest::SHA1

# will be remounted in development
COPY . $APP_HOME

COPY docker-entrypoint.sh /entrypoint.sh
CMD /entrypoint.sh
