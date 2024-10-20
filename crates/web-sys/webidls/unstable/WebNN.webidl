// https://www.w3.org/TR/webnn/#idl-index

interface mixin NavigatorML {
  [SecureContext, SameObject] readonly attribute ML ml;
};
Navigator includes NavigatorML;
WorkerNavigator includes NavigatorML;

enum MLDeviceType {
  "cpu",
  "gpu",
  "npu"
};

enum MLPowerPreference {
  "default",
  "high-performance",
  "low-power"
};

dictionary MLContextOptions {
  MLDeviceType deviceType = "cpu";
  MLPowerPreference powerPreference = "default";
};

[SecureContext, Exposed=(Window, DedicatedWorker)]
interface ML {
  Promise<MLContext> createContext(optional MLContextOptions options = {});
  Promise<MLContext> createContext(GPUDevice gpuDevice);
};

typedef record<USVString, ArrayBufferView> MLNamedArrayBufferViews;

dictionary MLComputeResult {
  MLNamedArrayBufferViews inputs;
  MLNamedArrayBufferViews outputs;
};

[SecureContext, Exposed=(Window, DedicatedWorker)]
interface MLContext {
  Promise<MLComputeResult> compute(
      MLGraph graph, MLNamedArrayBufferViews inputs, MLNamedArrayBufferViews outputs);
  
  MLOpSupportLimits opSupportLimits();
};

dictionary MLOpSupportLimits {
  MLInputOperandLayout preferredInputLayout;
  MLSupportLimits input;
  MLSupportLimits constant;
  MLSupportLimits output;
};

dictionary MLSupportLimits {
  sequence<MLOperandDataType> dataTypes;
};

dictionary MLBinarySupportLimits {
  MLSupportLimits a;
  MLSupportLimits b;
  MLSupportLimits output;
};

dictionary MLSingleInputSupportLimits {
  MLSupportLimits input;
  MLSupportLimits output;
};

[SecureContext, Exposed=(Window, DedicatedWorker)]
interface MLGraph {};

enum MLInputOperandLayout {
  "nchw",
  "nhwc"
};

enum MLOperandDataType {
  "float32",
  "float16",
  "int32",
  "uint32",
  "int64",
  "uint64",
  "int8",
  "uint8"
};

typedef [EnforceRange] unsigned long Index32;

dictionary MLOperandDescriptor {
  required MLOperandDataType dataType;
  required sequence<Index32> shape;
};

[SecureContext, Exposed=(Window, DedicatedWorker)]
interface MLOperand {
  MLOperandDataType dataType();
  sequence<unsigned long> shape();
};

dictionary MLOperatorOptions {
  USVString label = "";
};

typedef (bigint or unrestricted double) MLNumber;

typedef record<USVString, MLOperand> MLNamedOperands;

[SecureContext, Exposed=(Window, DedicatedWorker)]
interface MLGraphBuilder {
  // Construct the graph builder from the context.
  constructor(MLContext context);

  // Create an operand for a graph input.
  MLOperand input(USVString name, MLOperandDescriptor descriptor);

  // Create an operand for a graph constant.
  MLOperand constant(MLOperandDescriptor descriptor, ArrayBufferView bufferView);

  // Create a scalar operand from the specified number of the specified type.
  MLOperand constant(MLOperandDataType type, MLNumber value);

  // Compile the graph up to the specified output operands asynchronously.
  Promise<MLGraph> build(MLNamedOperands outputs);
};

dictionary MLArgMinMaxOptions : MLOperatorOptions {
  boolean keepDimensions = false;
  MLOperandDataType outputDataType = "int32";
};

partial interface MLGraphBuilder {
  MLOperand argMin(MLOperand input, [EnforceRange] unsigned long axis,
                   optional MLArgMinMaxOptions options = {});
  MLOperand argMax(MLOperand input, [EnforceRange] unsigned long axis,
                   optional MLArgMinMaxOptions options = {});
};

partial dictionary MLOpSupportLimits {
  MLSingleInputSupportLimits argMin;
  MLSingleInputSupportLimits argMax;
};

dictionary MLBatchNormalizationOptions : MLOperatorOptions {
  MLOperand scale;
  MLOperand bias;
  [EnforceRange] unsigned long axis = 1;
  double epsilon = 1e-5;
};

partial interface MLGraphBuilder {
  MLOperand batchNormalization(MLOperand input, MLOperand mean, MLOperand variance,
                               optional MLBatchNormalizationOptions options = {});
};

dictionary MLBatchNormalizationSupportLimits {
  MLSupportLimits input;
  MLSupportLimits mean;
  MLSupportLimits variance;
  MLSupportLimits scale;
  MLSupportLimits bias;
  MLSupportLimits output;
};

partial dictionary MLOpSupportLimits {
  MLBatchNormalizationSupportLimits batchNormalization;
};

partial interface MLGraphBuilder {
  MLOperand cast(MLOperand input,
                 MLOperandDataType type,
                 optional MLOperatorOptions options = {});
};

partial dictionary MLOpSupportLimits {
  MLSingleInputSupportLimits cast;
};

dictionary MLClampOptions : MLOperatorOptions {
  MLNumber minValue;
  MLNumber maxValue;
};

partial interface MLGraphBuilder {
  MLOperand clamp(MLOperand input, optional MLClampOptions options = {});
};

partial dictionary MLOpSupportLimits {
  MLSingleInputSupportLimits clamp;
};

partial interface MLGraphBuilder {
  MLOperand concat(sequence<MLOperand> inputs,
                   [EnforceRange] unsigned long axis,
                   optional MLOperatorOptions options = {});
};

dictionary MLConcatSupportLimits {
  MLSupportLimits inputs;
  MLSupportLimits output;
};

partial dictionary MLOpSupportLimits {
  MLConcatSupportLimits concat;
};

enum MLConv2dFilterOperandLayout {
  "oihw",
  "hwio",
  "ohwi",
  "ihwo"
};

dictionary MLConv2dOptions : MLOperatorOptions {
  sequence<Index32> padding;
  sequence<Index32> strides;
  sequence<Index32> dilations;
  [EnforceRange] unsigned long groups = 1;
  MLInputOperandLayout inputLayout = "nchw";
  MLConv2dFilterOperandLayout filterLayout = "oihw";
  MLOperand bias;
};

partial interface MLGraphBuilder {
  MLOperand conv2d(MLOperand input,
                   MLOperand filter,
                   optional MLConv2dOptions options = {});
};

dictionary MLConv2dSupportLimits {
  MLSupportLimits input;
  MLSupportLimits filter;
  MLSupportLimits bias;
  MLSupportLimits output;
};

partial dictionary MLOpSupportLimits {
  MLConv2dSupportLimits conv2d;
};

enum MLConvTranspose2dFilterOperandLayout {
  "iohw",
  "hwoi",
  "ohwi"
};

dictionary MLConvTranspose2dOptions : MLOperatorOptions {
  sequence<Index32> padding;
  sequence<Index32> strides;
  sequence<Index32> dilations;
  sequence<Index32> outputPadding;
  sequence<Index32> outputSizes;
  [EnforceRange] unsigned long groups = 1;
  MLInputOperandLayout inputLayout = "nchw";
  MLConvTranspose2dFilterOperandLayout filterLayout = "iohw";
  MLOperand bias;
};

partial interface MLGraphBuilder {
  MLOperand convTranspose2d(MLOperand input, MLOperand filter,
                            optional MLConvTranspose2dOptions options = {});
};

partial dictionary MLOpSupportLimits {
  MLConv2dSupportLimits convTranspose2d;
};

partial interface MLGraphBuilder {
  MLOperand add(MLOperand a, MLOperand b, optional MLOperatorOptions options = {});
  MLOperand sub(MLOperand a, MLOperand b, optional MLOperatorOptions options = {});
  MLOperand mul(MLOperand a, MLOperand b, optional MLOperatorOptions options = {});
  MLOperand div(MLOperand a, MLOperand b, optional MLOperatorOptions options = {});
  MLOperand max(MLOperand a, MLOperand b, optional MLOperatorOptions options = {});
  MLOperand min(MLOperand a, MLOperand b, optional MLOperatorOptions options = {});
  MLOperand pow(MLOperand a, MLOperand b, optional MLOperatorOptions options = {});
};

partial dictionary MLOpSupportLimits {
  MLBinarySupportLimits add;
  MLBinarySupportLimits sub;
  MLBinarySupportLimits mul;
  MLBinarySupportLimits div;
  MLBinarySupportLimits max;
  MLBinarySupportLimits min;
  MLBinarySupportLimits pow;
};

partial interface MLGraphBuilder {
  MLOperand equal(MLOperand a,
                  MLOperand b,
                  optional MLOperatorOptions options = {});
  MLOperand greater(MLOperand a,
                    MLOperand b,
                    optional MLOperatorOptions options = {});
  MLOperand greaterOrEqual(MLOperand a,
                           MLOperand b,
                           optional MLOperatorOptions options = {});
  MLOperand lesser(MLOperand a,
                   MLOperand b,
                   optional MLOperatorOptions options = {});
  MLOperand lesserOrEqual(MLOperand a,
                          MLOperand b,
                          optional MLOperatorOptions options = {});
  MLOperand logicalNot(MLOperand a, optional MLOperatorOptions options = {});
};

dictionary MLLogicalNotSupportLimits {
  MLSupportLimits a;
  MLSupportLimits output;
};

partial dictionary MLOpSupportLimits {
  MLBinarySupportLimits equal;
  MLBinarySupportLimits greater;
  MLBinarySupportLimits greaterOrEqual;
  MLBinarySupportLimits lesser;
  MLBinarySupportLimits lesserOrEqual;
  MLLogicalNotSupportLimits logicalNot;
};

partial interface MLGraphBuilder {
  MLOperand abs(MLOperand input, optional MLOperatorOptions options = {});
  MLOperand ceil(MLOperand input, optional MLOperatorOptions options = {});
  MLOperand cos(MLOperand input, optional MLOperatorOptions options = {});
  MLOperand erf(MLOperand input, optional MLOperatorOptions options = {});
  MLOperand exp(MLOperand input, optional MLOperatorOptions options = {});
  MLOperand floor(MLOperand input, optional MLOperatorOptions options = {});
  MLOperand identity(MLOperand input, optional MLOperatorOptions options = {});
  MLOperand log(MLOperand input, optional MLOperatorOptions options = {});
  MLOperand neg(MLOperand input, optional MLOperatorOptions options = {});
  MLOperand reciprocal(MLOperand input, optional MLOperatorOptions options = {});
  MLOperand sin(MLOperand input, optional MLOperatorOptions options = {});
  MLOperand sqrt(MLOperand input, optional MLOperatorOptions options = {});
  MLOperand tan(MLOperand input, optional MLOperatorOptions options = {});
};

partial dictionary MLOpSupportLimits {
  MLSingleInputSupportLimits abs;
  MLSingleInputSupportLimits ceil;
  MLSingleInputSupportLimits cos;
  MLSingleInputSupportLimits erf;
  MLSingleInputSupportLimits exp;
  MLSingleInputSupportLimits floor;
  MLSingleInputSupportLimits identity;
  MLSingleInputSupportLimits log;
  MLSingleInputSupportLimits neg;
  MLSingleInputSupportLimits reciprocal;
  MLSingleInputSupportLimits sin;
  MLSingleInputSupportLimits sqrt;
  MLSingleInputSupportLimits tan;
};

dictionary MLEluOptions : MLOperatorOptions {
  double alpha = 1;
};

partial interface MLGraphBuilder {
  MLOperand elu(MLOperand input, optional MLEluOptions options = {});
};

partial dictionary MLOpSupportLimits {
  MLSingleInputSupportLimits elu;
};

partial interface MLGraphBuilder {
  MLOperand expand(MLOperand input,
                   sequence<Index32> newShape,
                   optional MLOperatorOptions options = {});
};

partial dictionary MLOpSupportLimits {
  MLSingleInputSupportLimits expand;
};

dictionary MLGatherOptions : MLOperatorOptions {
  [EnforceRange] unsigned long axis = 0;
};

partial interface MLGraphBuilder {
  MLOperand gather(MLOperand input,
                   MLOperand indices,
                   optional MLGatherOptions options = {});
};

dictionary MLGatherSupportLimits {
  MLSupportLimits input;
  MLSupportLimits indices;
  MLSupportLimits output;
};

partial dictionary MLOpSupportLimits {
  MLGatherSupportLimits gather;
};

partial interface MLGraphBuilder {
  MLOperand gelu(MLOperand input, optional MLOperatorOptions options = {});
};

partial dictionary MLOpSupportLimits {
  MLSingleInputSupportLimits gelu;
};

dictionary MLGemmOptions : MLOperatorOptions {
  MLOperand c;
  double alpha = 1.0;
  double beta = 1.0;
  boolean aTranspose = false;
  boolean bTranspose = false;
};

partial interface MLGraphBuilder {
  MLOperand gemm(MLOperand a, MLOperand b, optional MLGemmOptions options = {});
};

dictionary MLGemmSupportLimits {
  MLSupportLimits a;
  MLSupportLimits b;
  MLSupportLimits c;
  MLSupportLimits output;
};

partial dictionary MLOpSupportLimits {
  MLGemmSupportLimits gemm;
};

enum MLGruWeightLayout {
  "zrn",  // update-reset-new gate ordering
  "rzn"   // reset-update-new gate ordering
};

enum MLRecurrentNetworkActivation {
  "relu",
  "sigmoid",
  "tanh"
};

enum MLRecurrentNetworkDirection {
  "forward",
  "backward",
  "both"
};

dictionary MLGruOptions : MLOperatorOptions {
  MLOperand bias;
  MLOperand recurrentBias;
  MLOperand initialHiddenState;
  boolean resetAfter = true;
  boolean returnSequence = false;
  MLRecurrentNetworkDirection direction = "forward";
  MLGruWeightLayout layout = "zrn";
  sequence<MLRecurrentNetworkActivation> activations;
};

partial interface MLGraphBuilder {
  sequence<MLOperand> gru(MLOperand input,
                          MLOperand weight,
                          MLOperand recurrentWeight,
                          [EnforceRange] unsigned long steps,
                          [EnforceRange] unsigned long hiddenSize,
                          optional MLGruOptions options = {});
};

dictionary MLGruSupportLimits {
  MLSupportLimits input;
  MLSupportLimits weight;
  MLSupportLimits recurrentWeight;
  MLSupportLimits bias;
  MLSupportLimits recurrentBias;
  MLSupportLimits initialHiddenState;
  MLSupportLimits outputs;
};

partial dictionary MLOpSupportLimits {
  MLGruSupportLimits gru;
};

dictionary MLGruCellOptions : MLOperatorOptions {
  MLOperand bias;
  MLOperand recurrentBias;
  boolean resetAfter = true;
  MLGruWeightLayout layout = "zrn";
  sequence<MLRecurrentNetworkActivation> activations;
};

partial interface MLGraphBuilder {
  MLOperand gruCell(MLOperand input,
                    MLOperand weight,
                    MLOperand recurrentWeight,
                    MLOperand hiddenState,
                    [EnforceRange] unsigned long hiddenSize,
                    optional MLGruCellOptions options = {});
};

dictionary MLGruCellSupportLimits {
  MLSupportLimits input;
  MLSupportLimits weight;
  MLSupportLimits recurrentWeight;
  MLSupportLimits hiddenState;
  MLSupportLimits bias;
  MLSupportLimits recurrentBias;
  MLSupportLimits output;
};

partial dictionary MLOpSupportLimits {
  MLGruCellSupportLimits gruCell;
};

dictionary MLHardSigmoidOptions : MLOperatorOptions {
  double alpha = 0.2;
  double beta = 0.5;
};

partial interface MLGraphBuilder {
  MLOperand hardSigmoid(MLOperand input, optional MLHardSigmoidOptions options = {});
};

partial dictionary MLOpSupportLimits {
  MLSingleInputSupportLimits hardSigmoid;
};

partial interface MLGraphBuilder {
  MLOperand hardSwish(MLOperand input, optional MLOperatorOptions options = {});
};

partial dictionary MLOpSupportLimits {
  MLSingleInputSupportLimits hardSwish;
};

dictionary MLInstanceNormalizationOptions : MLOperatorOptions {
  MLOperand scale;
  MLOperand bias;
  double epsilon = 1e-5;
  MLInputOperandLayout layout = "nchw";
};

partial interface MLGraphBuilder {
  MLOperand instanceNormalization(MLOperand input,
                                  optional MLInstanceNormalizationOptions options = {});
};

dictionary MLNormalizationSupportLimits {
  MLSupportLimits input;
  MLSupportLimits scale;
  MLSupportLimits bias;
  MLSupportLimits output;
};

partial dictionary MLOpSupportLimits {
  MLNormalizationSupportLimits instanceNormalization;
};

dictionary MLLayerNormalizationOptions : MLOperatorOptions {
  MLOperand scale;
  MLOperand bias;
  sequence<Index32> axes;
  double epsilon = 1e-5;
};

partial interface MLGraphBuilder {
  MLOperand layerNormalization(MLOperand input,
                               optional MLLayerNormalizationOptions options = {});
};

partial dictionary MLOpSupportLimits {
  MLNormalizationSupportLimits layerNormalization;
};

dictionary MLLeakyReluOptions : MLOperatorOptions {
  double alpha = 0.01;
};

partial interface MLGraphBuilder {
  MLOperand leakyRelu(MLOperand input, optional MLLeakyReluOptions options = {});
};

partial dictionary MLOpSupportLimits {
  MLSingleInputSupportLimits leakyRelu;
};

dictionary MLLinearOptions : MLOperatorOptions {
  double alpha = 1;
  double beta = 0;
};

partial interface MLGraphBuilder {
  MLOperand linear(MLOperand input, optional MLLinearOptions options = {});
};

partial dictionary MLOpSupportLimits {
  MLSingleInputSupportLimits linear;
};

enum MLLstmWeightLayout {
  "iofg", // input-output-forget-cell gate ordering
  "ifgo"  // input-forget-cell-output gate ordering
};

dictionary MLLstmOptions : MLOperatorOptions {
  MLOperand bias;
  MLOperand recurrentBias;
  MLOperand peepholeWeight;
  MLOperand initialHiddenState;
  MLOperand initialCellState;
  boolean returnSequence = false;
  MLRecurrentNetworkDirection direction = "forward";
  MLLstmWeightLayout layout = "iofg";
  sequence<MLRecurrentNetworkActivation> activations;
};

partial interface MLGraphBuilder {
  sequence<MLOperand> lstm(MLOperand input,
                           MLOperand weight,
                           MLOperand recurrentWeight,
                           [EnforceRange] unsigned long steps,
                           [EnforceRange] unsigned long hiddenSize,
                           optional MLLstmOptions options = {});
};

dictionary MLLstmSupportLimits {
  MLSupportLimits input;
  MLSupportLimits weight;
  MLSupportLimits recurrentWeight;
  MLSupportLimits bias;
  MLSupportLimits recurrentBias;
  MLSupportLimits peepholeWeight;
  MLSupportLimits initialHiddenState;
  MLSupportLimits initialCellState;
  MLSupportLimits outputs;
};

partial dictionary MLOpSupportLimits {
  MLLstmSupportLimits lstm;
};


dictionary MLLstmCellOptions : MLOperatorOptions {
  MLOperand bias;
  MLOperand recurrentBias;
  MLOperand peepholeWeight;
  MLLstmWeightLayout layout = "iofg";
  sequence<MLRecurrentNetworkActivation> activations;
};

partial interface MLGraphBuilder {
  sequence<MLOperand> lstmCell(MLOperand input,
                               MLOperand weight,
                               MLOperand recurrentWeight,
                               MLOperand hiddenState,
                               MLOperand cellState,
                               [EnforceRange] unsigned long hiddenSize,
                               optional MLLstmCellOptions options = {});
};

dictionary MLLstmCellSupportLimits {
  MLSupportLimits input;
  MLSupportLimits weight;
  MLSupportLimits recurrentWeight;
  MLSupportLimits hiddenState;
  MLSupportLimits cellState;
  MLSupportLimits bias;
  MLSupportLimits recurrentBias;
  MLSupportLimits peepholeWeight;
  MLSupportLimits outputs;
};

partial dictionary MLOpSupportLimits {
  MLLstmCellSupportLimits lstmCell;
};

partial interface MLGraphBuilder {
  MLOperand matmul(MLOperand a, MLOperand b, optional MLOperatorOptions options = {});
};

partial dictionary MLOpSupportLimits {
  MLBinarySupportLimits matmul;
};

enum MLPaddingMode {
  "constant",
  "edge",
  "reflection",
  "symmetric"
};

dictionary MLPadOptions : MLOperatorOptions {
  MLPaddingMode mode = "constant";
  MLNumber value = 0;
};

partial interface MLGraphBuilder {
  MLOperand pad(MLOperand input,
                sequence<Index32> beginningPadding,
                sequence<Index32> endingPadding,
                optional MLPadOptions options = {});
};

partial dictionary MLOpSupportLimits {
  MLSingleInputSupportLimits pad;
};

enum MLRoundingType {
  "floor",
  "ceil"
};

dictionary MLPool2dOptions : MLOperatorOptions {
  sequence<Index32> windowDimensions;
  sequence<Index32> padding;
  sequence<Index32> strides;
  sequence<Index32> dilations;
  MLInputOperandLayout layout = "nchw";
  MLRoundingType roundingType = "floor";
  sequence<Index32> outputSizes;
};

partial interface MLGraphBuilder {
  MLOperand averagePool2d(MLOperand input, optional MLPool2dOptions options = {});
  MLOperand l2Pool2d(MLOperand input, optional MLPool2dOptions options = {});
  MLOperand maxPool2d(MLOperand input, optional MLPool2dOptions options = {});
};

partial dictionary MLOpSupportLimits {
  MLSingleInputSupportLimits averagePool2d;
  MLSingleInputSupportLimits l2Pool2d;
  MLSingleInputSupportLimits maxPool2d;
};

partial interface MLGraphBuilder {
  MLOperand prelu(MLOperand input,
                  MLOperand slope,
                  optional MLOperatorOptions options = {});
};

dictionary MLPreluSupportLimits {
  MLSupportLimits input;
  MLSupportLimits slope;
  MLSupportLimits output;
};

partial dictionary MLOpSupportLimits {
  MLPreluSupportLimits prelu;
};

dictionary MLReduceOptions : MLOperatorOptions {
  sequence<Index32> axes;
  boolean keepDimensions = false;
};

partial interface MLGraphBuilder {
  MLOperand reduceL1(MLOperand input, optional MLReduceOptions options = {});
  MLOperand reduceL2(MLOperand input, optional MLReduceOptions options = {});
  MLOperand reduceLogSum(MLOperand input, optional MLReduceOptions options = {});
  MLOperand reduceLogSumExp(MLOperand input, optional MLReduceOptions options = {});
  MLOperand reduceMax(MLOperand input, optional MLReduceOptions options = {});
  MLOperand reduceMean(MLOperand input, optional MLReduceOptions options = {});
  MLOperand reduceMin(MLOperand input, optional MLReduceOptions options = {});
  MLOperand reduceProduct(MLOperand input, optional MLReduceOptions options = {});
  MLOperand reduceSum(MLOperand input, optional MLReduceOptions options = {});
  MLOperand reduceSumSquare(MLOperand input, optional MLReduceOptions options = {});
};

partial dictionary MLOpSupportLimits {
  MLSingleInputSupportLimits reduceL1;
  MLSingleInputSupportLimits reduceL2;
  MLSingleInputSupportLimits reduceLogSum;
  MLSingleInputSupportLimits reduceLogSumExp;
  MLSingleInputSupportLimits reduceMax;
  MLSingleInputSupportLimits reduceMean;
  MLSingleInputSupportLimits reduceMin;
  MLSingleInputSupportLimits reduceProduct;
  MLSingleInputSupportLimits reduceSum;
  MLSingleInputSupportLimits reduceSumSquare;
};

partial interface MLGraphBuilder {
  MLOperand relu(MLOperand input, optional MLOperatorOptions options = {});
};

partial dictionary MLOpSupportLimits {
  MLSingleInputSupportLimits relu;
};

enum MLInterpolationMode {
  "nearest-neighbor",
  "linear"
};

dictionary MLResample2dOptions : MLOperatorOptions {
  MLInterpolationMode mode = "nearest-neighbor";
  sequence<float> scales;
  sequence<Index32> sizes;
  sequence<Index32> axes;
};

partial interface MLGraphBuilder {
  MLOperand resample2d(MLOperand input, optional MLResample2dOptions options = {});
};

partial dictionary MLOpSupportLimits {
  MLSingleInputSupportLimits resample2d;
};

partial interface MLGraphBuilder {
  MLOperand reshape(MLOperand input,
                    sequence<Index32> newShape,
                    optional MLOperatorOptions options = {});
};

partial dictionary MLOpSupportLimits {
  MLSingleInputSupportLimits reshape;
};

partial interface MLGraphBuilder {
  MLOperand sigmoid(MLOperand input, optional MLOperatorOptions options = {});
};

partial dictionary MLOpSupportLimits {
  MLSingleInputSupportLimits sigmoid;
};

partial interface MLGraphBuilder {
  MLOperand slice(MLOperand input,
                  sequence<Index32> starts,
                  sequence<Index32> sizes,
                  optional MLOperatorOptions options = {});
};

partial  dictionary MLOpSupportLimits {
  MLSingleInputSupportLimits slice;
};

partial interface MLGraphBuilder {
  MLOperand softmax(MLOperand input,
                    [EnforceRange] unsigned long axis,
                    optional MLOperatorOptions options = {});
};

partial dictionary MLOpSupportLimits {
  MLSingleInputSupportLimits softmax;
};

partial interface MLGraphBuilder {
  MLOperand softplus(MLOperand input, optional MLOperatorOptions options = {});
};

partial dictionary MLOpSupportLimits {
  MLSingleInputSupportLimits softplus;
};

partial interface MLGraphBuilder {
  MLOperand softsign(MLOperand input, optional MLOperatorOptions options = {});
};

partial dictionary MLOpSupportLimits {
  MLSingleInputSupportLimits softsign;
};

dictionary MLSplitOptions : MLOperatorOptions {
  [EnforceRange] unsigned long axis = 0;
};

partial interface MLGraphBuilder {
  sequence<MLOperand> split(
      MLOperand input,
      ([EnforceRange] unsigned long or sequence<Index32>) splits,
      optional MLSplitOptions options = {});
};

dictionary MLSplitSupportLimits {
  MLSupportLimits input;
  MLSupportLimits outputs;
};

partial dictionary MLOpSupportLimits {
  MLSingleInputSupportLimits split;
};

partial interface MLGraphBuilder {
  MLOperand tanh(MLOperand input, optional MLOperatorOptions options = {});
};

partial dictionary MLOpSupportLimits {
  MLSingleInputSupportLimits tanh;
};

dictionary MLTransposeOptions : MLOperatorOptions {
  sequence<Index32> permutation;
};

partial interface MLGraphBuilder {
  MLOperand transpose(MLOperand input, optional MLTransposeOptions options = {});
};

partial dictionary MLOpSupportLimits {
  MLSingleInputSupportLimits transpose;
};

dictionary MLTriangularOptions : MLOperatorOptions {
  boolean upper = true;
  [EnforceRange] long diagonal = 0;
};

partial interface MLGraphBuilder {
  MLOperand triangular(MLOperand input, optional MLTriangularOptions options = {});
};

partial dictionary MLOpSupportLimits {
  MLSingleInputSupportLimits triangular;
};

partial interface MLGraphBuilder {
  MLOperand where(MLOperand condition,
                  MLOperand trueValue,
                  MLOperand falseValue,
                  optional MLOperatorOptions options = {});
};

dictionary MLWhereSupportLimits {
  MLSupportLimits condition;
  MLSupportLimits trueValue;
  MLSupportLimits falseValue;
  MLSupportLimits output;
};

partial dictionary MLOpSupportLimits {
  MLWhereSupportLimits where;
};
