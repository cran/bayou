// This file was generated by Rcpp::compileAttributes
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include <RcppArmadillo.h>
#include <Rcpp.h>

using namespace Rcpp;

// C_threepoint
SEXP C_threepoint(SEXP dat);
RcppExport SEXP bayou_C_threepoint(SEXP datSEXP) {
BEGIN_RCPP
    SEXP __sexp_result;
    {
        Rcpp::RNGScope __rngScope;
        Rcpp::traits::input_parameter< SEXP >::type dat(datSEXP );
        SEXP __result = C_threepoint(dat);
        PROTECT(__sexp_result = Rcpp::wrap(__result));
    }
    UNPROTECT(1);
    return __sexp_result;
END_RCPP
}
// C_transf_branch_lengths
SEXP C_transf_branch_lengths(SEXP dat, int model, NumericVector y, double alpha);
RcppExport SEXP bayou_C_transf_branch_lengths(SEXP datSEXP, SEXP modelSEXP, SEXP ySEXP, SEXP alphaSEXP) {
BEGIN_RCPP
    SEXP __sexp_result;
    {
        Rcpp::RNGScope __rngScope;
        Rcpp::traits::input_parameter< SEXP >::type dat(datSEXP );
        Rcpp::traits::input_parameter< int >::type model(modelSEXP );
        Rcpp::traits::input_parameter< NumericVector >::type y(ySEXP );
        Rcpp::traits::input_parameter< double >::type alpha(alphaSEXP );
        SEXP __result = C_transf_branch_lengths(dat, model, y, alpha);
        PROTECT(__sexp_result = Rcpp::wrap(__result));
    }
    UNPROTECT(1);
    return __sexp_result;
END_RCPP
}
// C_weightmatrix
SEXP C_weightmatrix(SEXP dat, SEXP parameters);
RcppExport SEXP bayou_C_weightmatrix(SEXP datSEXP, SEXP parametersSEXP) {
BEGIN_RCPP
    SEXP __sexp_result;
    {
        Rcpp::RNGScope __rngScope;
        Rcpp::traits::input_parameter< SEXP >::type dat(datSEXP );
        Rcpp::traits::input_parameter< SEXP >::type parameters(parametersSEXP );
        SEXP __result = C_weightmatrix(dat, parameters);
        PROTECT(__sexp_result = Rcpp::wrap(__result));
    }
    UNPROTECT(1);
    return __sexp_result;
END_RCPP
}
