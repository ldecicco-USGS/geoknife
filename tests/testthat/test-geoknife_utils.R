context("geoknife utils")


test_that("verbose", {
  testthat::skip_on_cran()
  expect_null(geoknife:::gverbose())
  gconfig(verbose=TRUE)
  expect_is(geoknife:::gverbose(), 'request')
  gconfig(verbose=FALSE)
  
})

test_that("error on url", {
  testthat::skip_on_cran()
  expect_error(geoknife:::retryVERB(httr::GET('bad.url.html')), "Couldn't resolve host name")
})

context("geoknife convienence functions for job state")

test_that("check status of empty job", {
  testthat::skip_on_cran()
  expect_equal(check(geojob())$status, 'none')
  expect_equal(check(geojob())$statusType, 'none')
  expect_equal(check(geojob())$percentComplete, 'none')
})

test_that("check status of an ID that is not valid", {
  testthat::skip_on_cran()
  expect_error(check(geojob(id='bad_id')), 'is not a valid geojob ID. Status cannot be checked')
})

test_that("check status of an ID that is incorrect", {
  testthat::skip_on_cran()
  fake.id <- 'bad_?id=asdf'
  status <- check(geojob(id=fake.id))
  expect_equal(status$status, "unknown")
  expect_equal(status$statusType, "unknown")
})

test_that("check status of an ID that doesn't exist", {
  testthat::skip_on_cran()
  fake.id <- "https://cida.usgs.gov:443/gdp/process/RetrieveResultServlet?id=bad"
  status <- check(geojob(id=fake.id))
  expect_equal(status$status, "unknown")
  expect_equal(status$statusType, "unknown")
})

fabric <- webdata('prism', variables = 'wrong')
job <- geoknife(c(-89,43), fabric, wait = TRUE)
failed.id <- id(job)
test_that("check status of an ID that failed", {
  testthat::skip_on_cran()
  status <- check(failed.id)
  expect_equal(status$statusType, "ProcessFailed")
})

test_that("result fails with failed job",{
  expect_error(result(failed.id), "processing is incomplete or has failed. See check()")
})

test_that("can create geojob from xml", {
  xmlLoc <- system.file("extdata", "testjob.xml",
                        package = "geoknife")
  job <- geojob(xml = xmlLoc)
  expect_equal(length(job@url), 0)
  expect_gt(length(job@xml), 0)
  jobWithURL <- geojob(xml = xmlLoc, url = "foo")
  expect_equal(jobWithURL@url, "foo")
})
