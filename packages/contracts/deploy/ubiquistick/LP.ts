import { DeployFuncParam } from "../utils";
import { create } from "../create"

export const optionDefinitions = [
    { name: 'task', defaultOption: true },
    { name: "network", alias: 'n', type: String },
]

const func = async (params: DeployFuncParam) => {
    const contractInstance = "src/ubiquistick/LP.sol:LP";
    const { env, args } = params;
    const { result, stderr } = await create({ ...env, name: args.task, network: args.network, contractInstance, constructorArguments: ["LP token", "LP"] });
    return !stderr ? "succeeded" : "failed"
}
export default func;