FROM public.ecr.aws/lambda/ruby:2.7

RUN yum install -y gcc gcc-c++ make tar xz patch

COPY Gemfile Gemfile.lock ${LAMBDA_TASK_ROOT}
ENV GEM_HOME=${LAMBDA_TASK_ROOT}
RUN bundle config set --local without 'development' && bundle install --frozen
COPY . ${LAMBDA_TASK_ROOT}

CMD [ "app.handler" ]
