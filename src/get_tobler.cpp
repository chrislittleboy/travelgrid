#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
NumericVector get_tobler(NumericVector x) {
  int n = x.size();
  NumericVector out(n);

  for (int i = 0; i < n; i++) {
    out[i] = 6 * std::exp(-3.5 * std::abs(std::tan(x[i]) + 0.05));
  }
  return out;
}
