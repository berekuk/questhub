FROM ubuntu:14.04

ENV APP_HOME /play/backend

# libssl-dev is needed by Email::Sender::Simple to send Amazon SES emails
RUN apt-get update && apt-get install -y libssl-dev sendmail curl supervisor make perl libgd2-xpm-dev

RUN curl -L https://cpanmin.us | perl - --sudo App::cpanminus

RUN cpanm --notest -i Flux::File Flux::Format::JSON Log::Any::Adapter MooX::Options Package::Variant Authen::SASL \
    Net::SMTP::SSL Email::Sender::Transport::SMTP::TLS Email::MIME Net::HTTP YAML Module::Install MongoDB \
    JSON Moo Class::XSAccessor Text::Markdown Clone Email::Sender Log::Any Try::Tiny LWP::Protocol::https \
    DateTime DateTime::Format::RFC3339 Image::Resize Type::Tiny
run cpan --notest -i Digest::SHA1

# needed for erb config generation
RUN apt-get install -y ruby

# will be remounted in development
COPY . $APP_HOME

WORKDIR $APP_HOME
CMD ./run.sh
