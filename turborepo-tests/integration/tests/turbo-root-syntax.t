Setup
  $ . ${TESTDIR}/../../helpers/setup_integration_test.sh

Test using $TURBO_ROOT$ in inputs and outputs
  $ mkdir -p fixtures/turbo_root_inputs_outputs/packages/pkg-a/dist
  $ cd fixtures/turbo_root_inputs_outputs
  $ echo 'console.log("root file");' > root-file.js
  $ cp ${TESTDIR}/turbo.json ./turbo.json
  $ git add . && git commit -m "Initial commit" --quiet

  $ ${TURBO} build --output-logs=hash-only
  \xe2\x80\xa2 Packages in scope: pkg-a (esc)
  \xe2\x80\xa2 Running build in 1 packages (esc)
  \xe2\x80\xa2 Remote caching disabled (esc)
  pkg-a:build: cache miss, executing *hash* (glob)
  
   Tasks:    1 successful, 1 total
  Cached:    0 cached, 1 total
    Time:    *ms (glob)

  $ test -f packages/pkg-a/dist/root-file.js
  $ cat packages/pkg-a/dist/root-file.js
  console.log("root file");
  $ rm packages/pkg-a/dist/root-file.js

  $ ${TURBO} build --output-logs=hash-only
  \xe2\x80\xa2 Packages in scope: pkg-a (esc)
  \xe2\x80\xa2 Running build in 1 packages (esc)
  \xe2\x80\xa2 Remote caching disabled (esc)
  pkg-a:build: cache hit, replaying output *hash* (glob)
  
   Tasks:    1 successful, 1 total
  Cached:    1 cached, 1 total
    Time:    *ms (glob)

  $ test -f packages/pkg-a/dist/root-file.js
  $ cat packages/pkg-a/dist/root-file.js
  console.log("root file");

  $ echo "console.log('modified');" > root-file.js

  $ ${TURBO} build --output-logs=hash-only
  \xe2\x80\xa2 Packages in scope: pkg-a (esc)
  \xe2\x80\xa2 Running build in 1 packages (esc)
  \xe2\x80\xa2 Remote caching disabled (esc)
  pkg-a:build: cache miss, executing *hash* (glob)
  
   Tasks:    1 successful, 1 total
  Cached:    0 cached, 1 total
    Time:    *ms (glob)

  $ cat packages/pkg-a/dist/root-file.js
  console.log('modified');

Test using $TURBO_ROOT$ in outputs only
  $ cd ../turbo_root_outputs_only
  $ mkdir -p .
  $ cp ${TESTDIR}/turbo.json ./turbo.json
  $ git add . && git commit -m "Initial commit" --quiet

  $ ${TURBO} build --output-logs=hash-only
  \xe2\x80\xa2 Packages in scope: turbo_root_outputs_only (esc)
  \xe2\x80\xa2 Running build in 1 packages (esc)
  \xe2\x80\xa2 Remote caching disabled (esc)
  turbo_root_outputs_only:build: cache miss, executing *hash* (glob)
  
   Tasks:    1 successful, 1 total
  Cached:    0 cached, 1 total
    Time:    *ms (glob)

  $ test -f root-output.js
  $ cat root-output.js
  root output
  $ rm root-output.js

  $ ${TURBO} build --output-logs=hash-only
  \xe2\x80\xa2 Packages in scope: turbo_root_outputs_only (esc)
  \xe2\x80\xa2 Running build in 1 packages (esc)
  \xe2\x80\xa2 Remote caching disabled (esc)
  turbo_root_outputs_only:build: cache hit, replaying output *hash* (glob)
  
   Tasks:    1 successful, 1 total
  Cached:    1 cached, 1 total
    Time:    *ms (glob)

  $ test -f root-output.js
  $ cat root-output.js
  root output

Test error when using $TURBO_ROOT$ in globalDependencies
  $ cd ../turbo_root_global_deps_error
  $ mkdir -p .
  $ cp ${TESTDIR}/turbo.json ./turbo.json
  $ git add . && git commit -m "Initial commit" --quiet

  $ ${TURBO} build --output-logs=hash-only
  ERROR: $TURBO_ROOT$ syntax is not allowed in globalDependencies
  [1] 
