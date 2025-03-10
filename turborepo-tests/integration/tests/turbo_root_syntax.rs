use std::fs;

use turborepo_tests::{
    get_fixture_dir, get_fixture_out_dir, run_fixture_test, run_fixture_test_with_opts, TestFixture,
};

#[test]
fn test_turbo_root_syntax() {
    let fixture = TestFixture::new("turbo_root_syntax", "./fixtures/turbo_root_syntax", None);
    let out_dir = get_fixture_out_dir("turbo_root_syntax");
    let fixture_dir = get_fixture_dir("turbo_root_syntax");

    // First run - should execute and cache
    run_fixture_test(
        &fixture,
        &["build", "test"],
        &[
            "build: cache miss, executing",
            "test: cache miss, executing",
        ],
    );

    // Verify files were copied
    assert!(out_dir.join("packages/pkg-a/dist/util.js").exists());
    assert!(out_dir.join("packages/pkg-a/coverage/setup.js").exists());

    // Delete the output files to test cache restoration
    fs::remove_file(out_dir.join("packages/pkg-a/dist/util.js")).unwrap();
    fs::remove_file(out_dir.join("packages/pkg-a/coverage/setup.js")).unwrap();

    // Second run - should restore from cache
    run_fixture_test(
        &fixture,
        &["build", "test"],
        &[
            "build: cache hit, replaying output",
            "test: cache hit, replaying output",
        ],
    );

    // Verify files were restored from cache
    assert!(out_dir.join("packages/pkg-a/dist/util.js").exists());
    assert!(out_dir.join("packages/pkg-a/coverage/setup.js").exists());

    // Modify a root file
    fs::write(
        fixture_dir.join("shared/util.js"),
        "module.exports = { add: (a, b) => a + b + 1 };",
    )
    .unwrap();

    // Third run - should execute again due to root file change
    run_fixture_test(&fixture, &["build"], &["build: cache miss, executing"]);

    // Verify the new file was copied
    let util_contents = fs::read_to_string(out_dir.join("packages/pkg-a/dist/util.js")).unwrap();
    assert!(util_contents.contains("a + b + 1"));
}

#[test]
fn test_turbo_root_syntax_in_global_deps() {
    let fixture = TestFixture::new("turbo_root_syntax", "./fixtures/turbo_root_syntax", None);
    let fixture_dir = get_fixture_dir("turbo_root_syntax");

    // First run - should execute and cache
    run_fixture_test(&fixture, &["build"], &["build: cache miss, executing"]);

    // Create the file referenced in globalDependencies
    fs::create_dir_all(fixture_dir.join("some")).unwrap();
    fs::write(fixture_dir.join("some/path"), "some content").unwrap();

    // Second run - should execute again due to global dependency change
    run_fixture_test(&fixture, &["build"], &["build: cache miss, executing"]);
}
